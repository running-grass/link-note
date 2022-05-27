import { Column, Entity, Index, JoinColumn, ManyToOne, OneToOne, PrimaryGeneratedColumn, UpdateDateColumn, VersionColumn } from "typeorm";
import { Base } from "./base.entity";
import { User } from "./user.entity";

@Entity({})
export class Workspace extends Base{
    @ManyToOne(() => User, user => user.workspaces)
    @JoinColumn({
        name: "ownerId"
    })
    @Index()
    owner: User;

    @Column({comment: "工作空间名称,英文"})
    @Index({unique: true})
    name!: string

    @Column({comment: "工作空间的显示名称"})
    displayName!: string
}
