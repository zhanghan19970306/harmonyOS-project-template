import { geoLocationManager } from "@kit.LocationKit"
import { map, mapCommon } from "@kit.MapKit"

export class LocationUtils {

  /** 获取WGS84经纬度 */
  static async getWGS84Location() {
    return await geoLocationManager.getCurrentLocation({
      "priority": geoLocationManager.LocationRequestPriority.FIRST_FIX,
      "scenario": geoLocationManager.LocationRequestScenario.UNSET,
      "maxAccuracy": 0
    })
  }

  /** 逆地理信息 耗时20ms */
  static async getAddressesFromLocation(locationInfo: geoLocationManager.Location) {
    return await geoLocationManager.getAddressesFromLocation(locationInfo)
  }

  /** WGS84转化为GCJ02 */
  static async WGS84ToGCJ02(locationInfo: geoLocationManager.Location) {
    return map.convertCoordinate(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, locationInfo)
  }

}