import { useParams } from "react-router-dom";
import { CardDto, CardType, useCreateNewCardMutation, useFindTopicQuery } from "../../generated/graphql";
import './TopicDetail.css';

// 新建类型便于类型检测
interface MinCard<S> {
    id: number
    content: string
    childrens: S[]
}

export const CardTree = <T extends MinCard<T>> ({ cards, parent, createNewCard}: { cards: T[], parent?: T, createNewCard: (a?: number) => void}) => {
    if (!cards?.length) {
        return null;
    }


    const onKeyUp = (ev: React.KeyboardEvent<HTMLInputElement>) => {
        if (ev.code === "Enter") {
            createNewCard(parent?.id);
        }
    }
    return <section className="card-tree">
        { cards.map(card => (
            <section className="card-box" key={card.id}>
                {/* <header className="card-header">{card.content}</header> */}
                <input 
                    className="card-header" 
                    value={card.content}
                    onKeyUp={onKeyUp}
                    />
                <CardTree cards={card.childrens} parent={card} createNewCard={createNewCard} />
            </section>
        ))}
    </section>
}


export default function TopicDetail() {
  const { title } = useParams();

  const { data, refetch } = useFindTopicQuery({
    variables: {
      title,
    },
  });

  const [createCard] = useCreateNewCardMutation();

  const topicId = data?.topic?.id;

  if (!topicId) {
      return <h2>没有该主题【${title}】</h2>
  }



  const createNewCard = async  (parentId?: number) => {
    await createCard({variables: {
        belongId: topicId,
        parentId,
        content: '',
        cardType: CardType.Inline,
    }});
    refetch();
  }
  // const a: CardDto = data?.topic?.cards[1].childrens[2];
  return (
    <div>
      i am a topic: {data?.topic?.id} <br />
      <CardTree cards={data?.topic?.cards ?? []} createNewCard={createNewCard}/>

    </div>
  );
}
