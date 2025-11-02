
/*===============================================================================
Copyright (c) 2024 PTC Inc. and/or Its Subsidiary Companies. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other
countries.
===============================================================================*/

#import <Foundation/Foundation.h>
#import <VuforiaEngine/VuforiaEngine.h>

#import <UIKit/UIOrientation.h>

#ifdef __cplusplus
extern "C"
{
#endif

/// Vuforia initialization parameter structure for Swift
typedef struct
{
    void* classPtr;
    void (*errorCallback)(void*, const char*);
    void (*initDoneCallback)(void*);
    VuRenderVBBackendType vbRenderBackend;
    UIInterfaceOrientation interfaceOrientation;
} VuforiaInitConfig;


/// 3D Model representation for Swift
typedef struct
{
    bool isLoaded;
    int numVertices;
    const float* vertices;
    const float* textureCoordinates;
} VuforiaModel;


int getImageTargetId();
int getModelTargetId();

void initAR(VuforiaInitConfig config, int target);
bool startAR();
void stopAR();
void deinitAR();

bool isARStarted();
void cameraPerformAutoFocus();
void cameraRestoreAutoFocus();

void configureRendering(int width, int height, void* orientation);

bool getVideoBackgroundTextureSize(VuVector2I* textureSize);

bool prepareToRender(double* viewport, void* metalDevice, void* texture, void* encoder);
void finishRender();

void getVideoBackgroundProjection(void* mvp);
VuMesh* getVideoBackgroundMesh();

bool getOrigin(void* projection, void* modelView);
bool getImageTargetResult(void* projection, void* modelView, void* scaledModelView);
bool getModelTargetResult(void* projection, void* modelView, void* scaledModelView);
bool getModelTargetGuideView(void* mvp, VuImageInfo* guideViewImage, VuBool* guideViewHasChanged);

VuPlatformARKitInfo getARKitInfo();

VuforiaModel loadModel(const char* const data, int dataSize);
void releaseModel(VuforiaModel* model);

typedef struct
{
    const unsigned short NUM_SQUARE_VERTEX;
    const unsigned short NUM_SQUARE_INDEX;
    const unsigned short NUM_SQUARE_WIREFRAME_INDEX;
    const float* squareVertices;
    const float* squareTexCoords;
    const unsigned short* squareIndices;
    const unsigned short* squareWireframeIndices;

    const unsigned short NUM_CUBE_VERTEX;
    const unsigned short NUM_CUBE_INDEX;
    const unsigned short NUM_CUBE_WIREFRAME_INDEX;
    const float* cubeVertices;
    const float* cubeTexCoords;
    const unsigned short* cubeIndices;
    const unsigned short* cubeWireframeIndices;

    const unsigned short NUM_AXIS_INDEX;
    const unsigned short NUM_AXIS_VERTEX;
    const unsigned short NUM_AXIS_COLOR;
    const float* axisVertices;
    const float* axisColors;
    const unsigned short* axisIndices;

} Models_t;

/// Instance of the struct populated with model data for use in Swift
extern Models_t Models;

#ifdef __cplusplus
};
#endif
