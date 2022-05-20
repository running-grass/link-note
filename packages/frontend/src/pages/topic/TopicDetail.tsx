import { MutableRefObject, useEffect, useState } from "react";
import { useParams } from "react-router-dom";

import { KeyHandler } from "hotkeys-js";
import { useHotkeys, Options } from "react-hotkeys-hook";

import { CardStore } from "../../mobx/Card.store";
import { TopicStore } from "../../mobx/Topic.store";
import "./TopicDetail.css";

import { observer } from "mobx-react"; // Or "mobx-react".

enum KEYMAP {
  NAV_UP = "shift+up",
  NAV_DOWN = "shift+down",
  NAV_LEFT = "shift+left",
  NAV_RIGHT = "shift+right",

  NEW_NEXT = "enter",
  NEW_PREV = "cmd+shift+enter",

  MOVE_UP = "cmd+shift+up,cmd+shift+p",
  MOVE_DOWN = "cmd+shift+down,cmd+shift+n",
  MOVE_LEFT = "cmd+shift+left,shift+tab",
  MOVE_RIGHT = "cmd+shift+right,tab",
}

// export declare function use2Hotkeys<T extends Element>(keys: string, callback: KeyHandler, options?: Options, deps?: any[]): React.MutableRefObject<T | null>;

const useMultHotkeys = <T extends Element>(
  listens: { [propName: string]: KeyHandler },
  option?: Options,
  deps?: any[]
): MutableRefObject<T | null> => {
  const keyListens: { [propName: string]: KeyHandler } = {};
  Object.entries(listens).forEach(([k, v]) => {
    // 把多对一的键绑定拆开
    k.split(",").forEach((k1) => {
      keyListens[k1] = v;
    });
  });

  const almost = Object.keys(keyListens).join(",");

  return useHotkeys(
    almost,
    (ke, he) => {
      const handler = keyListens[he.key];
      if (handler) {
        handler(ke, he);
      }
    },
    option,
    deps
  );
};

export const CardBody = observer(({ card }: { card: CardStore }) => {
  const ref = useMultHotkeys<HTMLInputElement>(
    {
      [KEYMAP.NAV_UP]: () => {
        console.log(card.id + "up");
      },
      [KEYMAP.NAV_DOWN]: () => {
        console.log(card.id + "down");
      },
      [KEYMAP.NAV_LEFT]: () => {
        console.log(card.id + "left");
      },
      [KEYMAP.NAV_RIGHT]: () => {
        console.log(card.id + "right");
      },
      [KEYMAP.NEW_NEXT]: (ev, hv) => {
        const target = ev.currentTarget as HTMLInputElement

        // target.
        card.createNextCard();
      },
      [KEYMAP.MOVE_UP]: () => {
        card.moveUp();
      },
      [KEYMAP.MOVE_DOWN]: () => {
        card.moveDown();
      },
      [KEYMAP.MOVE_LEFT]: () => {
        card.moveLevelUp();
      },
      [KEYMAP.MOVE_RIGHT]: () => {
        card.moveLevelDown();
      },
    },
    {
      enableOnTags: ["INPUT"],
    },
    [card]
  );

  const onContentChange = (ev: React.ChangeEvent<HTMLInputElement>) => {
    card.changeContent(ev.currentTarget.value);
  };

  return (
    <input
      ref={ref}
      className="card-header"
      defaultValue={card.content}
      onChange={onContentChange}
    />
  );
});

export const CardTree = observer(
  ({ cards }: { cards: CardStore[]; parent?: CardStore }) => {
    if (!cards?.length) {
      return null;
    }

    return (
      <section className="card-tree">
        {cards.map((card) => (
          <section className="card-box" key={card.id}>
            {/* <header className="card-header">{card.content}</header> */}
            <CardBody card={card} />
            <CardTree cards={card.childrens} />
          </section>
        ))}
      </section>
    );
  }
);

export const TopicDetail = observer(() => {
  console.log("topic");

  const { title } = useParams();

  let [topicStore, setTopic] = useState<TopicStore | null>(null);

  useEffect(() => {
    if (title) {
      TopicStore.fromTitle(title).then(setTopic);
    }
  }, [title]);

  useEffect(() => {
    if (topicStore) {
      if (!topicStore.cards.length) {
        topicStore.createNewRootCard();
      }
    }
  }, [topicStore]);

  // 自动保存
  useEffect(() => {
    const timer = setInterval(() => {
      topicStore?.updateCardsToServer();
    }, 3000);
    return () => {
      clearInterval(timer);
    };
  }, [topicStore]);

  if (!title) {
    return null;
  }

  if (!topicStore) {
    return <h2>没有该主题【${title}】</h2>;
  }

  return (
    <div>
      i am a topic: {topicStore.title} <br />
      <CardTree cards={topicStore.cards} />
    </div>
  );
});
