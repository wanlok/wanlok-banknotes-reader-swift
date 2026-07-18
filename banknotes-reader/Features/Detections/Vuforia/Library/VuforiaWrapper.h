
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
    void (*detectionCallback)(void*, const char*);
    VuRenderVBBackendType vbRenderBackend;
    UIInterfaceOrientation interfaceOrientation;
} VuforiaInitConfig;


typedef void (*DetectionCallback)(const char* targetName);

int getImageTargetId();

void initAR(VuforiaInitConfig config, int target, char* fileName, char** targetNames, int targetCount);
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

bool getImageTargetResult(void* projection, void* modelView, void* scaledModelView);

VuPlatformARKitInfo getARKitInfo();

typedef struct
{
    const unsigned short NUM_SQUARE_VERTEX;
    const unsigned short NUM_SQUARE_INDEX;
    const unsigned short NUM_SQUARE_WIREFRAME_INDEX;
    const float* squareVertices;
    const float* squareTexCoords;
    const unsigned short* squareIndices;
    const unsigned short* squareWireframeIndices;

} Models_t;

/// Instance of the struct populated with model data for use in Swift
extern Models_t Models;

#ifdef __cplusplus
};
#endif
