import { Column, Entity, Index, OneToMany, OneToOne } from "typeorm";
import { Auth } from "./auth.entity";
import { Base } from "./base.entity";
import { Workspace } from "./workspace.entity";

@Entity()
export class User extends Base{
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

    @OneToOne(() => Auth, auth => auth.user)
    auth: Auth

    @OneToMany(() => Workspace, workspace => workspace.owner)
    workspaces: Workspace[]
}
