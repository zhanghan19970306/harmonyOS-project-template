import { isString } from "lodash"

interface RGB {
  r: number
  g: number
  b: number
  a?: number
}

interface RGBA extends RGB {
  a: number
}

interface HSV {
  h: number
  s: number
  v: number
  a: number
}

interface HSL {
  h: number
  s: number
  l: number
  a: number
}

export class ColorUtils {
  /**
   * 解析并验证透明度值
   * @param a - 输入的透明度值
   * @returns 有效的透明度值（0-1之间的数字，默认为1）
   */
  static parseAlpha(a?: number) {
    return a !== undefined && !Number.isNaN(+a) && +a >= 0 && +a <= 1 ? +a : 1
  }

  /**
   * 将数值限制在0到指定最大值之间
   * @param value - 需要限制的数值
   * @param max - 最大值
   */
  static boundValue(value: number, max: number) {
    value = Math.min(max, Math.max(0, value))
    if (Math.abs(value - max) < 0.000001) {
      return 1
    }
    return (value % max) / Math.floor(max)
  }

  /**
   * 判断是否为十六进制颜色
   * @param color - 颜色字符串
   */
  static isHexColor(color: string) {
    return /^#([0-9a-fA-f]{3}|[0-9a-fA-f]{6}|[0-9a-fA-f]{8})$/.test(color)
  }

  /**
   * 判断是否为rgb颜色字符串
   * @param color - 颜色字符串
   * @returns 是否为rgb颜色字符串
   */
  static isRgbColor(color: string) {
    return /^rgb\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*\)$/i.test(color)
  }

  /**
   * 判断是否为rgba颜色字符串
   * @param color - 颜色字符串
   * @returns 是否为rgba颜色字符串
   */
  static isRgbaColor(color: string) {
    return /^rgba\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(0|1|0?\.\d+)\s*\)$/i.test(color)
  }

  /**
   * 获取rgba颜色字符串
   * @param color - RGBA 或 RGB 颜色对象
   * @returns rgba颜色字符串
   */
  static rgba2Str(color: RGB | RGBA) {
    if (color.a) {
      return `rgba(${color.r},${color.g},${color.b},${color.a})`
    }
    return `rgba(${color.r},${color.g},${color.b},1)`
  }

  /**
   * 十六进制颜色转换为 RGBA 颜色模型
   * @param color - 十六进制颜色字符串
   * @returns RGB 颜色对象
   */
  static hex2rgba(color: string): RGBA {
    if (!ColorUtils.isHexColor(color)) {
      throw new Error("参数格式不是hex颜色")
    }

    let hexColor = color.replace(/^#/, "")
    let a = 1 // 默认透明度为1

    if (hexColor.length === 3) {
      hexColor = hexColor
        .split("")
        .map(c => c + c)
        .join("") // 将3位的十六进制颜色转换为6位
    } else if (hexColor.length === 8) {
      // 透明度计算
      const alphaHex = hexColor.slice(6, 8)
      a = Number((parseInt(alphaHex, 16) / 255).toFixed(2)) // 保留两位小数并确保返回数字
      hexColor = hexColor.slice(0, 6) // 去除透明度部分
    }

    const r = parseInt(hexColor.slice(0, 2), 16)
    const g = parseInt(hexColor.slice(2, 4), 16)
    const b = parseInt(hexColor.slice(4, 6), 16)

    return {
      r,
      g,
      b,
      a
    }
  }

  /**
   * RGB 或 RGBA 颜色模型转换为十六进制颜色
   * @param param - RGB 或 RGBA 颜色对象或字符串
   * @returns 十六进制颜色字符串
   */
  static rgb2hex(param: RGB | string): string {
    if (typeof param === "string" && ColorUtils.isHexColor(param)) {
      return param
    }

    let r: number
    let g: number
    let b: number
    let a: number | undefined

    if (typeof param === "string") {
      const match = param.match(/^rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*(\d*\.?\d+))?\)$/)
      if (!match) {
        throw new Error("参数格式错误")
      }
      r = parseInt(match[1], 10)
      g = parseInt(match[2], 10)
      b = parseInt(match[3], 10)
      a = match[4] ? parseFloat(match[4]) : undefined
    } else {
      r = param.r
      g = param.g
      b = param.b
      a = param.a
    }

    const _ = [r, g, b]
      .map(v => {
        const hexValue = v.toString(16)
        return hexValue.length < 2 ? `0${hexValue}` : hexValue
      })
      .join("")

    const hex = `#${_}`

    if (a !== undefined && a !== 1) {
      const alpha = Math.round(a * 255)
      const alphaHex = alpha.toString(16)
        .padStart(2, "0")
        .toUpperCase()
      return `${hex}${alphaHex}`
    }

    return hex
  }

  /**
   * 十六进制颜色转换为 RGBA 格式
   * @param color - 十六进制颜色字符串
   * @returns RGBA 颜色字符串
   */
  static hex2rgbaStr = (color: string): string => {
    const sColor = color.toLowerCase()
    if (ColorUtils.isHexColor(sColor)) {
      return ColorUtils.rgba2Str(ColorUtils.hex2rgba(sColor))
    }
    return sColor
  }

  /**
   * 从 RGBA 字符串中提取颜色数据
   * @param rgba - RGBA 颜色字符串
   * @returns RGB 颜色对象
   */
  static str2rgba(rgba: string): RGBA {

    const arr = rgba
      .replace(/rgba?\(/i, "")
      .replace(/\)/, "")
      .replace(/[\s+]/g, "")
      .split(",")

    return {
      r: parseInt(arr[0], 10),
      g: parseInt(arr[1], 10),
      b: parseInt(arr[2], 10),
      a: parseFloat(arr[3] || "1")
    }
  }

  static color2Rgba(color: ResourceStr, a = 1): ResourceStr {
    if (!isString(color)) {
      return color
    }

    let _color: RGBA

    if (ColorUtils.isHexColor(color)) {
      _color = ColorUtils.hex2rgba(color)
    } else if (ColorUtils.isRgbColor(color) || ColorUtils.isRgbaColor(color)) {
      _color = ColorUtils.str2rgba(color)
    } else {
      return ""
    }

    _color.a = a

    return ColorUtils.rgba2Str(_color)

  }

}