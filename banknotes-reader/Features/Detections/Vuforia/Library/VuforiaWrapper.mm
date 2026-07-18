/*===============================================================================
Copyright (c) 2024 PTC Inc. and/or Its Subsidiary Companies. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other
countries.
===============================================================================*/

#include "VuforiaWrapper.h"

#include "AppController.h"
#include "Models.h"

AppController controller;

struct
{
    void* callbackClass = nullptr;
    void (*errorCallbackMethod)(void*, const char*) = nullptr;
    void (*initDoneCallbackMethod)(void*) = nullptr;
    void (*detectionCallbackMethod)(void*, const char*) = nullptr;
} gWrapperData;


extern "C"
{

int
getImageTargetId()
{
    return AppController::IMAGE_TARGET_ID;
}


void
initAR(VuforiaInitConfig config, int target, char* fileName, char** targetNames, int targetCount)
{
    // Hold onto pointers for later use by the lambda passed to initAR below
    gWrapperData.callbackClass = config.classPtr;
    gWrapperData.errorCallbackMethod = config.errorCallback;
    gWrapperData.initDoneCallbackMethod = config.initDoneCallback;
    gWrapperData.detectionCallbackMethod = config.detectionCallback;

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
    initConfig.detectionCallback = [](const char* targetName) {
        gWrapperData.detectionCallbackMethod(gWrapperData.callbackClass, targetName);
    };

    // Call AppController to initialize Vuforia ...
    controller.initAR(initConfig, target, fileName, targetNames, targetCount);
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


// Map the static Model data into the struct instance exposed to Swift
Models_t Models = {
    NUM_SQUARE_VERTEX,
    NUM_SQUARE_INDEX,
    NUM_SQUARE_WIREFRAME_INDEX,
    squareVertices,
    squareTexCoords,
    squareIndices,
    squareWireframeIndices,
};

} // extern "C"
