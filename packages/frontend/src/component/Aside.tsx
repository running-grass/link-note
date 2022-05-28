import { Divider, Input, Select, Space, Typography } from "antd"
import { observer } from "mobx-react"
import { useContext } from "react"
import { GlobalStoreContext } from "../context/globalStore.context"
import { PlusOutlined } from '@ant-design/icons';


export const Aside = observer(() => {
  const global = useContext(GlobalStoreContext)!

  const workspaces = global.workspaces

  const onWorkspaceChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    // setName(event.target.value);
    // global.currWorkspaceId = event.target
  };

  const addItem = (e: React.MouseEvent<HTMLAnchorElement>) => {
    e.preventDefault();
    // setItems([...items, name || `New item ${index++}`]);
    // setName('');
  };

  const onSelect = (val : number) => {
    console.log(val)
  }


  return <aside className="w-60 flex flex-col bg-pink-200 p-4">
     <Select
      onSelect={onSelect}
      placeholder="选择工作空间"
      defaultValue={global.currWorkspaceId}
      dropdownRender={menu => (
        <>
          {menu}
          <Divider style={{ margin: '8px 0' }} />
          <Space align="center" style={{ padding: '0 8px 4px' }}>
            <Input placeholder="Please enter item" value="23" onChange={onWorkspaceChange} />
            <Typography.Link onClick={addItem} style={{ whiteSpace: 'nowrap' }}>
              <PlusOutlined /> Add item
            </Typography.Link>
          </Space>
        </>
      )}
    >
      {workspaces.map(item => (
        <Select.Option key={item.id} value={item.id}>{item.displayName}</Select.Option>
      ))}
    </Select>
  </aside>
})