// https://juejin.cn/post/7368777511952990234

import { util } from "@kit.ArkTS"
import { window } from "@kit.ArkUI"
import { AssetStore } from "./assetStore"

export class DeviceUtils {
  private static deviceIdCacheKey = "device_id_cache_key"
  private static deviceId = ""

  /**
   * 获取设备id>32为随机码[卸载APP后依旧不变]
   */
  static async getDeviceId() {
    let deviceId = DeviceUtils.deviceId
    //如果内存缓存为空，则从AssetStore中读取
    if (DeviceUtils.isEmpty(deviceId)) {
      deviceId = `${(await AssetStore.get(DeviceUtils.deviceIdCacheKey)).data}`
    }
    //如果AssetStore中未读取到，则随机生成32位随机码，然后缓存到AssetStore中
    if (DeviceUtils.isEmpty(deviceId)) {
      deviceId = util.generateRandomUUID(true).replace(new RegExp("-", "gm"), "")
      AssetStore.set(DeviceUtils.deviceIdCacheKey, deviceId)
    }
    DeviceUtils.deviceId = deviceId
    return deviceId
  }

  /*
  * 切换窗口为隐私模式 (禁止截屏/录屏)
  * */
  static async togglePrivacyMode(mode: boolean = true) {
    const windowClass = await window.getLastWindow(getContext())
    await windowClass.setWindowPrivacyMode(mode)
  }

  /**
   * 判断字符串是否为空
   * @param property 被检测的字符串
   */
  private static isEmpty(property?: string | null): Boolean {
    if (property == "" || property == null || property == undefined || property == "undefined" ||
      property.length == 0) {
      return true
    }
    return false
  }

}

