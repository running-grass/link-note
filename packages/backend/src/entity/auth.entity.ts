import { Column, Entity, Index, JoinColumn, OneToOne, PrimaryColumn, PrimaryGeneratedColumn, UpdateDateColumn, VersionColumn } from "typeorm";
import { Base } from "./base.entity";
import { User } from "./user.entity";

@Entity({
    withoutRowid: true
})
export class Auth extends Base {
    @OneToOne(() => User, user => user.auth, {
        onDelete: "CASCADE"
    })
    @JoinColumn({
        name: "uid"
    })
    @Index({unique: true})
    user: User;

    @Column({
        comment: "存储明文密码"
    })
    password: string
}
