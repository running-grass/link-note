import { CreateDateColumn, DeleteDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn, VersionColumn } from "typeorm";

import { Guid } from "src/util/type";
import { guidLength } from "src/util/common";

@Entity()
export abstract class Base {
    @PrimaryColumn({
        length: guidLength
    })
    id: Guid;

    @CreateDateColumn()
    @Index()
    createAt: Date;

    @UpdateDateColumn()
    @Index()
    updatedAt: Date;

    @DeleteDateColumn()   
    @Index()
    deletedAt: Date

    @VersionColumn()
    version: number
}