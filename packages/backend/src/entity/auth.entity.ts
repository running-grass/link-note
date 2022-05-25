import { Column, Entity, Index, JoinColumn, OneToOne, PrimaryGeneratedColumn, UpdateDateColumn, VersionColumn } from "typeorm";
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
    @Index({unique: true})
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
