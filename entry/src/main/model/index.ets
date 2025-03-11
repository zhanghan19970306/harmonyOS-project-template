export * from "./vo"

/** lazyForEach实体类 */
@Observed
export class LazyDataSource<T> implements IDataSource {
  private listeners: DataChangeListener[] = []
  private originDataArray: T[] = []

  constructor(data?: T[]) {
    data?.forEach(item => this.pushData(item))
  }

  public totalCount(): number {
    return this.originDataArray.length
  }

  public getData(index: number): T {
    return this.originDataArray[index]
  }

  public addData(index: number, data: T): void {
    this.originDataArray.splice(index, 0, data)
    this.notifyDataAdd(index)
  }

  public pushData(data: T | T[]): void {
    if (Array.isArray(data)) {
      data.forEach(item => {
        this.originDataArray.push(item)
        this.notifyDataAdd(this.originDataArray.length - 1)
      })
    } else {
      this.originDataArray.push(data)
      this.notifyDataAdd(this.originDataArray.length - 1)
    }
  }

  public deleteData(index: number): void {
    this.originDataArray.splice(index, 1)
    this.notifyDataDelete(index)
  }

  public clear(): void {
    const len = this.originDataArray.length
    this.originDataArray = []
    let i = len - 1
    while (i >= 0) {
      // 需要反向通知 删除对应索引
      this.notifyDataDelete(i--)
    }
  }

  public moveData(from: number, to: number): void {
    const temp: T = this.originDataArray[from]
    this.originDataArray[from] = this.originDataArray[to]
    this.originDataArray[to] = temp
    this.notifyDataMove(from, to)
  }

  // 该方法为框架侧调用，为LazyForEach组件向其数据源处添加listener监听
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  // 该方法为框架侧调用，为对应的LazyForEach组件在数据源处去除listener监听
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      console.info("remove listener")
      this.listeners.splice(pos, 1)
    }
  }

  // 通知LazyForEach组件需要重载所有子组件
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded()
    })
  }

  // 通知LazyForEach组件需要在index对应索引处添加子组件
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index)
    })
  }

  // 通知LazyForEach组件在index对应索引处数据有变化，需要重建该子组件
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index)
    })
  }

  // 通知LazyForEach组件需要在index对应索引处删除该子组件
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index)
    })
  }

  // 通知LazyForEach组件将from索引和to索引处的子组件进行交换
  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to)
    })
  }
}