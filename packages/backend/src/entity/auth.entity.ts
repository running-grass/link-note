import { Column, CreateDateColumn, DeleteDateColumn, Entity, Index, JoinColumn, OneToOne, PrimaryColumn, PrimaryGeneratedColumn, UpdateDateColumn, VersionColumn } from "typeorm";
import { User } from "./user.entity";

@Entity()
export class Auth {
    @PrimaryGeneratedColumn({
    })
    id: number

    @OneToOne(() => User, {
        onDelete: "CASCADE"
    })
    @JoinColumn({
        name: "uid"
    })
    user: User;

    @UpdateDateColumn()
    @Index()
    updatedAt: Date;

    @VersionColumn()
    version: number

    @Column({
        comment: "存储明文密码"
    })
    password: string
}
