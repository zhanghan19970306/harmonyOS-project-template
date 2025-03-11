import { Api } from "../../api"
import { preferencesUtils } from "../../shared/preferencesUtils"

@Entry
@Component
struct Index {
  @State message: string = "Hello World"

  async aboutToAppear() {
    await preferencesUtils.get("isFirstLaunch", false)
    const _ = await Api.Config.getCountryCodeJson()
    console.log(`___ -> ${JSON.stringify(_)}`)
  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id("HelloWorld")
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: "__container__", align: VerticalAlign.Center },
          middle: { anchor: "__container__", align: HorizontalAlign.Center }
        })
    }
    .height("100%")
    .width("100%")
  }
}