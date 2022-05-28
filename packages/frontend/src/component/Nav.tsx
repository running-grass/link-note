import { Menu } from "antd";
import { useCallback } from "react";
import { useNavigate } from "react-router-dom";

export const Nav = () => {
  const navigator = useNavigate();

  const onSelect = useCallback((info: any) => {
    switch (info.key) {
      case 'topic':
        navigator('/topic')
        break
      default:
        navigator('/')
    }
  }, [navigator])


  // >=4.20.0 可用，推荐的写法 ✅
  const items = [
    { label: '主题', key: 'topic' }, // 菜单项务必填写 key
    { label: '文件', key: 'file', disabled: true },
    { label: '图片', key: 'image', disabled: true },
  ];
  return <Menu items={items} mode="horizontal" onSelect={onSelect} theme="light" />;
}
