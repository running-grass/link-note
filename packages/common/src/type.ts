// 使用Nono生成的id，目前长度为15
export type Guid = string

export type JwtUser = {
  uid: Guid,
  username: string,
}