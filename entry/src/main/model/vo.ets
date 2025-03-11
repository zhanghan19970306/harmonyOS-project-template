export class BaseVO<T> {
  metaData: T

  constructor(metaData: T) {
    this.metaData = metaData
  }
}

