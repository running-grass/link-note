import { ArgsType, Field, Int } from '@nestjs/graphql';
import { BaseSort, Order } from 'src/enum/common';

@ArgsType()
export class TopicsArgs {
    @Field(type => BaseSort, {
        nullable: true 
    })
    sort?: BaseSort = BaseSort.createAt;

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