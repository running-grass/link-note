import { CreateDateColumn, DeleteDateColumn, Entity, Index, PrimaryGeneratedColumn, UpdateDateColumn, VersionColumn } from "typeorm";

@Entity()
export abstract class Base {
    @PrimaryGeneratedColumn()
    id: number;

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