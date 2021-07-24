module RxDB.Type where

-- rxdb中的实体
foreign import data RxDatabase :: Type
foreign import data RxCollection :: Type -> Type
foreign import data RxDocument :: Type -> Type
foreign import data RxQuery :: Type -> Type

-- 复杂的json格式
foreign import data RxSchema :: Type
foreign import data QueryObject :: Type 

foreign import emptyQueryObject :: QueryObject

-- 插件模块
foreign import data PouchPlugin :: Type
