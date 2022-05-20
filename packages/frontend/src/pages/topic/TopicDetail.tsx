import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { CardStore } from "../../mobx/Card.store";
import { TopicStore } from "../../mobx/Topic.store";
import "./TopicDetail.css";

import { observer } from "mobx-react"; // Or "mobx-react".

export const CardBody = observer(({ card }: { card: CardStore }) => {

  const onKeyUp = async (ev: React.KeyboardEvent<HTMLInputElement>) => {
    if (ev.code === "Enter") {
      await card.createNextCard();
    }
  };

  const onContentChange = (ev: React.ChangeEvent<HTMLInputElement>) => {
    card.changeContent(ev.currentTarget.value)
  }

  return (
    <input
      className="card-header"
      defaultValue={card.content}
      onChange={onContentChange}
      onKeyUp={onKeyUp}
    />
  )
})

export const CardTree = observer(({
  cards
}: {
  cards: CardStore[];
  parent?: CardStore;
}) => {
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
})

export const TopicDetail = observer(() => {
  console.log('topic')

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
