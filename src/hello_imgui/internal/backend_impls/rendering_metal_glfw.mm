#ifdef HELLOIMGUI_HAS_METAL
#ifdef HELLOIMGUI_USE_GLFW3

#include "rendering_metal.h"

#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>
#include <backends/imgui_impl_metal.h>
#include <array>

#include "hello_imgui/hello_imgui.h"

#define GLFW_INCLUDE_NONE
#define GLFW_EXPOSE_NATIVE_COCOA
#include <GLFW/glfw3.h>
#include <GLFW/glfw3native.h>
#include <backends/imgui_impl_glfw.h>


namespace HelloImGui
{

    GlfwMetalGlobals& GetGlfwMetalGlobals()
    {
            static GlfwMetalGlobals sGlfwMetalGlobals;
            return sGlfwMetalGlobals;
    }

    void PrepareGlfwForMetal_WithWindow_PreImGuiInit(GLFWwindow* glfwWindow)
    {
        auto& gMetalGlobals = GetMetalGlobals();
        auto& gGlfwMetalGlobals = GetGlfwMetalGlobals();

        gGlfwMetalGlobals.glfwWindow = glfwWindow;
        gGlfwMetalGlobals.mtlDevice = MTLCreateSystemDefaultDevice();
        gMetalGlobals.mtlCommandQueue = [gGlfwMetalGlobals.mtlDevice newCommandQueue];
    }

    void PrepareGlfwForMetal_PosImGuiInit()
    {
        auto& gMetalGlobals = GetMetalGlobals();

        auto& gGlfwMetalGlobals = GetGlfwMetalGlobals();
        ImGui_ImplGlfw_InitForOther(gGlfwMetalGlobals.glfwWindow, true);
        ImGui_ImplMetal_Init(gGlfwMetalGlobals.mtlDevice);

        NSWindow *nswin = glfwGetCocoaWindow(gGlfwMetalGlobals.glfwWindow);
        gMetalGlobals.caMetalLayer = [CAMetalLayer layer];
        gMetalGlobals.caMetalLayer.device = gGlfwMetalGlobals.mtlDevice;
        gMetalGlobals.caMetalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
        nswin.contentView.layer = gMetalGlobals.caMetalLayer;
        nswin.contentView.wantsLayer = YES;

        gMetalGlobals.mtlRenderPassDescriptor = [MTLRenderPassDescriptor new];
    }

    RenderingCallbacksPtr CreateBackendCallbacks_GlfwMetal()
    {
        auto callbacks = PrepareBackendCallbacksCommon();

        callbacks->Impl_GetFrameBufferSize = []
        {
            auto& gGlfwMetalGlobals = GetGlfwMetalGlobals();
            int width, height;
            glfwGetFramebufferSize(gGlfwMetalGlobals.glfwWindow, &width, &height);
            return ScreenSize{width, height};
        };

        return callbacks;
    }

} // namespace HelloImGui

#endif // HELLOIMGUI_USE_GLFW3
#endif // HELLOIMGUI_HAS_METAL