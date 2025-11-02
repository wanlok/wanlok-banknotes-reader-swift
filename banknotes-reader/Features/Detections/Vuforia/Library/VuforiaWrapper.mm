/*===============================================================================
Copyright (c) 2024 PTC Inc. and/or Its Subsidiary Companies. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other
countries.
===============================================================================*/

#include "VuforiaWrapper.h"

#include "AppController.h"
#include "MemoryStream.h"
#include "Models.h"
#include "tiny_obj_loader.h"

#include <vector>

AppController controller;

struct
{
    void* callbackClass = nullptr;
    void (*errorCallbackMethod)(void*, const char*) = nullptr;
    void (*initDoneCallbackMethod)(void*) = nullptr;

} gWrapperData;


/// Method to load obj model files, uses C++ so outside extern block
bool loadObjModel(const char* const data, int dataSize, int& numVertices, float** vertices, float** texCoords);


extern "C"
{

int
getImageTargetId()
{
    return AppController::IMAGE_TARGET_ID;
}


int
getModelTargetId()
{
    return AppController::MODEL_TARGET_ID;
}


void
initAR(VuforiaInitConfig config, int target)
{
    // Hold onto pointers for later use by the lambda passed to initAR below
    gWrapperData.callbackClass = config.classPtr;
    gWrapperData.errorCallbackMethod = config.errorCallback;
    gWrapperData.initDoneCallbackMethod = config.initDoneCallback;

    // Create InitConfig structure and populate...
    AppController::InitConfig initConfig;
    initConfig.vbRenderBackend = config.vbRenderBackend;
    initConfig.appData = &config.interfaceOrientation;
    initConfig.errorMessageCallback = [](const char* errorString) {
        gWrapperData.errorCallbackMethod(gWrapperData.callbackClass, errorString);
    };
    initConfig.vuforiaEngineErrorCallback = [](VuErrorCode errorCode) {
        NSLog(@"Vuforia engine error callback invoked. Error code: 0x%02x", errorCode);

        switch (errorCode)
        {
            case VU_ENGINE_ERROR_INVALID_LICENSE:
                gWrapperData.errorCallbackMethod(gWrapperData.callbackClass, "License key validation has failed, Engine has been stopped.");
                break;
            case VU_ENGINE_ERROR_CAMERA_DEVICE_LOST:
                gWrapperData.errorCallbackMethod(gWrapperData.callbackClass,
                                                 "Camera device lost (the device has been disconnected or has become unavailable for "
                                                 "another reason)");
                break;
            default:
                NSLog(@"Got an unexpected Engine error code 0x%02x", errorCode);
                assert(false);
                break;
        }
    };
    initConfig.initDoneCallback = []() { gWrapperData.initDoneCallbackMethod(gWrapperData.callbackClass); };

    // Call AppController to initialize Vuforia ...
    controller.initAR(initConfig, target);
}


bool
startAR()
{
    return controller.startAR();
}


void
stopAR()
{
    controller.stopAR();
}


void
deinitAR()
{
    controller.deinitAR();
}


bool
isARStarted()
{
    return controller.isARStarted();
}


void
cameraPerformAutoFocus()
{
    controller.cameraPerformAutoFocus();
}


void
cameraRestoreAutoFocus()
{
    controller.cameraRestoreAutoFocus();
}


void
configureRendering(int width, int height, void* orientation)
{
    controller.configureRendering(width, height, orientation);
}

bool
getVideoBackgroundTextureSize(VuVector2I* textureSize)
{
    return controller.getVideoBackgroundTextureSize(*textureSize);
}

bool
prepareToRender(double* viewport, void* metalDevice, void* texture, void* encoder)
{
    // Integer to hold the texture unit which is always 0 for Metal
    static int textureUnit = 0;

    VuRenderVideoBackgroundData renderVideoBackgroundData;
    renderVideoBackgroundData.renderData = encoder;
    renderVideoBackgroundData.textureData = texture;
    renderVideoBackgroundData.textureUnitData = &textureUnit;

    return controller.prepareToRender(viewport, &renderVideoBackgroundData);
}


void
finishRender()
{
    controller.finishRender();
}


// contents is a 16 element float array
void
getVideoBackgroundProjection(void* mvp)
{
    auto renderState = controller.getRenderState();

    memset(mvp, 0, 16 * sizeof(float));
    memcpy(mvp, renderState.vbProjectionMatrix.data, sizeof(renderState.vbProjectionMatrix.data));
}


VuMesh*
getVideoBackgroundMesh()
{
    auto renderState = controller.getRenderState();
    assert(renderState.vbMesh);
    return renderState.vbMesh;
}

bool
getOrigin(void* projection, void* modelView)
{
    VuMatrix44F projectionMat44;
    VuMatrix44F modelViewMat44;
    if (controller.getOrigin(projectionMat44, modelViewMat44))
    {
        memcpy(projection, &projectionMat44.data, sizeof(projectionMat44.data));
        memcpy(modelView, &modelViewMat44.data, sizeof(modelViewMat44.data));
        return true;
    }

    return false;
}


bool
getImageTargetResult(void* projection, void* modelView, void* scaledModelView)
{
    VuMatrix44F projectionMatrix;
    VuMatrix44F modelViewMatrix;
    VuMatrix44F scaledModelViewMatrix;
    if (controller.getImageTargetResult(projectionMatrix, modelViewMatrix, scaledModelViewMatrix))
    {
        memcpy(projection, &projectionMatrix.data, sizeof(projectionMatrix.data));
        memcpy(modelView, &modelViewMatrix.data, sizeof(modelViewMatrix.data));
        memcpy(scaledModelView, &scaledModelViewMatrix.data, sizeof(scaledModelViewMatrix.data));

        return true;
    }

    return false;
}


bool
getModelTargetResult(void* projection, void* modelView, void* scaledModelView)
{
    VuMatrix44F projectionMatrix;
    VuMatrix44F modelViewMatrix;
    VuMatrix44F scaledModelViewMatrix;
    if (controller.getModelTargetResult(projectionMatrix, modelViewMatrix, scaledModelViewMatrix))
    {
        memcpy(projection, &projectionMatrix.data, sizeof(projectionMatrix.data));
        memcpy(modelView, &modelViewMatrix.data, sizeof(modelViewMatrix.data));
        memcpy(scaledModelView, &scaledModelViewMatrix.data, sizeof(scaledModelViewMatrix.data));

        return true;
    }

    return false;
}


bool
getModelTargetGuideView(void* mvp, VuImageInfo* guideViewImage, VuBool* guideViewImageHasChanged)
{
    VuMatrix44F projection;
    VuMatrix44F modelView;
    if (controller.getModelTargetGuideView(projection, modelView, *guideViewImage, *guideViewImageHasChanged))
    {
        VuMatrix44F modelViewProjection = vuMatrix44FMultiplyMatrix(projection, modelView);
        memcpy(mvp, &modelViewProjection.data, sizeof(modelViewProjection.data));


        return true;
    }

    return false;
}


VuPlatformARKitInfo
getARKitInfo()
{
    auto platformController = controller.getPlatformController();
    assert(platformController);

    VuFusionProviderPlatformType fusionProviderPlatformType{ VU_FUSION_PROVIDER_PLATFORM_TYPE_UNKNOWN };
    vuPlatformControllerGetFusionProviderPlatformType(platformController, &fusionProviderPlatformType);
    if (fusionProviderPlatformType != VU_FUSION_PROVIDER_PLATFORM_TYPE_ARKIT)
    {
        // ARKit is not in use
        return { nullptr, nullptr };
    }

    VuPlatformARKitInfo arkitInfo;
    if (vuPlatformControllerGetARKitInfo(platformController, &arkitInfo) != VU_SUCCESS)
    {
        // Error getting ARKitInfo
        NSLog(@"Error getting ARKit info");
        return { nullptr, nullptr };
    }

    return arkitInfo;
}


VuforiaModel
loadModel(const char* const data, int dataSize)
{
    int numVertices = 0;
    float* rawVertices = nullptr;
    float* rawTexCoords = nullptr;

    bool ret = loadObjModel(data, dataSize, numVertices, &rawVertices, &rawTexCoords);

    return VuforiaModel{
        ret,
        numVertices,
        rawVertices,
        rawTexCoords,
    };
}


void
releaseModel(VuforiaModel* model)
{
    model->isLoaded = false;
    model->numVertices = 0;
    delete[] model->vertices;
    model->vertices = nullptr;
    delete[] model->textureCoordinates;
    model->textureCoordinates = nullptr;
}


// Map the static Model data into the struct instance exposed to Swift
Models_t Models = {
    NUM_SQUARE_VERTEX,
    NUM_SQUARE_INDEX,
    NUM_SQUARE_WIREFRAME_INDEX,
    squareVertices,
    squareTexCoords,
    squareIndices,
    squareWireframeIndices,
    NUM_CUBE_VERTEX,
    NUM_CUBE_INDEX,
    NUM_CUBE_WIREFRAME_INDEX,
    cubeVertices,
    cubeTexCoords,
    cubeIndices,
    cubeWireframeIndices,
    NUM_AXIS_INDEX,
    NUM_AXIS_VERTEX,
    NUM_AXIS_COLOR,
    axisVertices,
    axisColors,
    axisIndices,
};

} // extern "C"


bool
loadObjModel(const char* const data, int dataSize, int& numVertices, float** vertices, float** texCoords)
{
    tinyobj::attrib_t attrib;
    std::vector<tinyobj::shape_t> shapes;
    std::vector<tinyobj::material_t> materials;

    std::string warn;
    std::string err;

    MemoryInputStream aFileDataStream(data, dataSize);
    bool ret = tinyobj::LoadObj(&attrib, &shapes, &materials, &warn, &err, &aFileDataStream);
    if (ret && err.empty())
    {
        numVertices = 0;
        std::vector<float> vecVertices;
        std::vector<float> vecTexCoords;

        // Loop over shapes
        // s is the index into the shapes vector
        // f is the index of the current face
        // v is the index of the current vertex
        for (size_t s = 0; s < shapes.size(); ++s)
        {
            // Loop over faces(polygon)
            size_t index_offset = 0;
            for (size_t f = 0; f < shapes[s].mesh.num_face_vertices.size(); ++f)
            {
                int fv = shapes[s].mesh.num_face_vertices[f];
                numVertices += fv;

                // Loop over vertices in the face.
                for (size_t v = 0; v < fv; ++v)
                {
                    // access to vertex
                    tinyobj::index_t idx = shapes[s].mesh.indices[index_offset + v];

                    vecVertices.push_back(attrib.vertices[3 * idx.vertex_index + 0]);
                    vecVertices.push_back(attrib.vertices[3 * idx.vertex_index + 1]);
                    vecVertices.push_back(attrib.vertices[3 * idx.vertex_index + 2]);

                    // The model may not have texture coordinates for every vertex
                    // If a texture coordinate is missing we just set it to 0,0
                    // This may not be suitable for rendering some OBJ model files
                    if (idx.texcoord_index < 0)
                    {
                        vecTexCoords.push_back(0.f);
                        vecTexCoords.push_back(0.f);
                    }
                    else
                    {
                        vecTexCoords.push_back(attrib.texcoords[2 * idx.texcoord_index + 0]);
                        vecTexCoords.push_back(attrib.texcoords[2 * idx.texcoord_index + 1]);
                    }
                }
                index_offset += fv;
            }
        }

        *vertices = new float[vecVertices.size() * 3];
        memcpy(*vertices, vecVertices.data(), vecVertices.size() * sizeof(float));
        *texCoords = new float[vecTexCoords.size() * 2];
        memcpy(*texCoords, vecTexCoords.data(), vecTexCoords.size() * sizeof(float));
    }

    return ret;
}
