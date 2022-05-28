import { observer } from "mobx-react";
import { useCallback } from "react";
import { useClickAway } from 'react-use'
import { CardStore } from "../../../mobx/Card.store";
import { useMultHotkeys, KEYMAP } from "../../../utils/hook";

const restorePositon = (card: CardStore, target: HTMLInputElement | null) => {
  if (!target) return;
  card.belong.setNeedFocus({
    card,
    pos: target.selectionStart ?? undefined,
  });
};

export const CardEditInput = observer(({ card }: { card: CardStore }) => {
  const ref: React.MutableRefObject<HTMLInputElement | null> = useMultHotkeys<HTMLInputElement>(
    {
      [KEYMAP.NAV_PLANT_UP]: (ev) => {
        ev.preventDefault()

        card.navToPlantUp();
      },
      [KEYMAP.NAV_PLANT_DOWN]: (ev) => {
        ev.preventDefault()

        card.navToPlantDown();
      },
      // [KEYMAP.NAV_LEFT]: () => {
      //   console.log(card.id + "left");
      // },
      // [KEYMAP.NAV_RIGHT]: () => {
      //   console.log(card.id + "right");
      // },
      [KEYMAP.BACKSPACE]: (ev) => {
        ev.preventDefault()

        const target = ev.target as HTMLInputElement;

        if (target.selectionStart === null) {
          return;
        }
        card.deleteAt(target.selectionStart).then((pos) => {
          if (pos !== null) {
            target.setSelectionRange(pos, pos);
          }
        });
        return true;
      },
      [KEYMAP.NEW_NEXT]: (ev, hv) => {
        ev.preventDefault()

        const target = ev.target as HTMLInputElement;
        if (ref.current !== target) {
          return;
        }

        const selection = window.getSelection();

        if (!selection) {
          return;
        }

        if (target.selectionStart !== null && target.selectionEnd !== null) {
          card.createNextCard(target.selectionStart, target.selectionEnd);
        }
      },
      [KEYMAP.MOVE_UP]: (ev) => {
        ev.preventDefault()

        card.moveUp();
        restorePositon(card, ref.current);
      },
      [KEYMAP.MOVE_DOWN]: (ev) => {
        ev.preventDefault()

        card.moveDown();
        restorePositon(card, ref.current);
      },
      [KEYMAP.MOVE_LEFT]: (ev) => {
        ev.preventDefault()
        card.moveLevelUp();
        restorePositon(card, ref.current);
      },
      [KEYMAP.MOVE_RIGHT]: (ev) => {
        ev.preventDefault()
        card.moveLevelDown();
        restorePositon(card, ref.current);
      },
    },
    {
      enableOnTags: ["INPUT", "TEXTAREA"],
      enabled: true,
    },
    [card]
  );


  useClickAway(ref, () => {
    card.belong.setCurrentCard();
    // alert('OUTSIDE CLICKED');
  });

  const onContentChange = (ev: React.ChangeEvent<HTMLInputElement>) => {
    card.changeContent(ev.currentTarget.value);
  };

  return (
    <input
      ref={ref}
      className="card-header"
      id={`card-header-${card.id}`}
      value={card.content}
      onChange={onContentChange}
    />
  );
})

export const CardBody = observer(({ card }: { card: CardStore }) => {

  const startEditing = useCallback(() => {
    card.belong.setNeedFocus({
      card,
      pos: 10000
    });
    console.log('set current')
  }, [card])

  console.log('card body', card.belong.currentEditingCard ,card.isEditing)
  return (
    card.isEditing ? <CardEditInput card={card} /> : <div
      id={`card-header-${card.id}`}

      className="card-header"
      onClick={startEditing}
    >

      {card.content}
    </div>

  );
});



export const CardTree = observer(
  ({ cards }: { cards: CardStore[]; parent?: CardStore }) => {
    if (!cards.length) {
      return null;
    }

    return (
      <section className="card-tree bg-gray-50">
        {cards.map((card) => (
          <section className="card-box" key={card.id}>
            <CardBody card={card} />
            <CardTree cards={card.childrens} />
          </section>
        ))}
      </section>
    );
  }
);

