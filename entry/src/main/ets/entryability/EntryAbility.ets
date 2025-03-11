import { AbilityConstant, UIAbility, Want } from "@kit.AbilityKit"
import { window } from "@kit.ArkUI"
import { webview } from "@kit.ArkWeb"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { AppUtil } from "@pura/harmony-utils"
import { BW_H5_SITE } from "BuildProfile"

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 在 Web 组件初始化之前，通过此接口加载 Web 引擎的动态库文件，以提高启动性能。自动预连接历史访问过的高频网站。
    webview.WebviewController.initializeWebEngine()
    webview.WebviewController.prepareForPageLoad(BW_H5_SITE, true, 2)

    AppUtil.init(this.context)
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    try {
      await windowStage.loadContent("pages/Index")

      const windowClass = await windowStage.getMainWindow()
      windowClass.setWindowSystemBarProperties({
        statusBarContentColor: "#000"
      })

    } catch (err) {
      if (err.code) {
        hilog.error(0x0000, "testTag", "Failed to load the content. Cause: %{public}s", JSON.stringify(err) ?? "")
        return
      }
      hilog.info(0x0000, "testTag", "Succeeded in loading the content.")
    }
  }

}
