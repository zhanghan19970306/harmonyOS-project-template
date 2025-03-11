import { CountryEntity } from ".."
import { request } from "../../shared"

/** 获取国际区号 */
export async function getCountryCodeJson() {
  return await request.$get<CountryEntity[]>("https://images.qmai.cn/area/global.json",
    { $returnRaw: true, cacheTime: 5 * 60 * 1000 })
}
