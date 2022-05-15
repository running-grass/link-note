import { ArgsType, Field, Int, registerEnumType } from '@nestjs/graphql';
import { NodeDtoSort, Order } from 'src/graphql/model';


registerEnumType(NodeDtoSort, { name: "NodeDtoSort" });
registerEnumType(Order, { name: "Order" });

@ArgsType()
export class TopicsArgs {
    @Field(type => NodeDtoSort, { nullable: true })
    sort?: NodeDtoSort = NodeDtoSort.createDate;

    @Field(type => Order, {
        description: "正序或者倒序",
        nullable: true
    })
    order?: Order = Order.DESC;

    @Field(type => Int, { nullable: true })
    limit?: number = 10;

    @Field({ description: "搜索的关键字", nullable: true })
    search?: string;
}