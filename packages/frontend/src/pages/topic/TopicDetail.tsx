import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { observer } from "mobx-react"; // Or "mobx-react".

import { TopicStore } from "../../mobx/Topic.store";
import { CardTree } from "./component/CardTree";

import "./TopicDetail.css";

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

  useEffect(() => {
    const timer = setInterval(() => {
      topicStore?.updateCardsToServer();
    }, 3000);
    return () => {
      clearInterval(timer);
    };
  }, [topicStore]);

  // 新节点变动的情况下
  useEffect(() => {
    console.log("effect");

    if (!topicStore?.needFocus) {
      return;
    }
    const needFocus = topicStore.needFocus;
    topicStore.clearNeedFocus();

    const el = document.getElementById(
      `card-header-${needFocus.card.id}`
    ) as HTMLInputElement | null;

    if (!el) {
      return;
    }

    if ( el  instanceof HTMLInputElement) {

      el.focus();
      if (needFocus.pos !== undefined) {
        el.setSelectionRange(needFocus.pos, needFocus.pos);
      }
    }

  }, [topicStore?.needFocus]);

  if (!title) {
    return null;
  }

  if (!topicStore) {
    return <h2>没有该主题【${title}】</h2>;
  }

  return (
    <div>
      <h2>{topicStore.title} </h2>
      <CardTree cards={topicStore.cards} />
    </div>
  );
});
