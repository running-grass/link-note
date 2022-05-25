import { Column, CreateDateColumn, DeleteDateColumn, Entity, Index, PrimaryGeneratedColumn, UpdateDateColumn, VersionColumn } from "typeorm";

@Entity()
export class User {
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

    // TODO 不能和email、phone的规则重叠
    @Index({ unique: true })
    @Column()
    username: string

    @Column({ nullable: true})
    @Index({ unique: true })
    email?: string

    @Column({ nullable: true})
    @Index({ unique: true})
    phone?: string
}
