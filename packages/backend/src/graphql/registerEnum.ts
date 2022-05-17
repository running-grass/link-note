import { registerEnumType } from '@nestjs/graphql';
import { CardType, Order, BaseSort } from 'src/enum/common';

registerEnumType(BaseSort, { name: "BaseSort", description: "实体查询中的通用排序字段" });
registerEnumType(Order, { name: "Order", description: "所有查询、排序通用的排序" });
registerEnumType(CardType, { name: "CardType", description: "Card内容的类型" });
