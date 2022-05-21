import { observer } from "mobx-react";

import { CardStore } from "../../../mobx/Card.store";
import { useMultHotkeys, KEYMAP } from "../../../utils/hook";

export const CardBody = observer(({ card }: { card: CardStore }) => {
  const restorePositon = (target: HTMLInputElement | null) => {
    if (!target) return;
    card.belong.setNeedFocus({
      card,
      pos: target.selectionStart ?? undefined,
    });
  };

  const ref = useMultHotkeys<HTMLInputElement>(
    {
      [KEYMAP.NAV_PLANT_UP]: () => {
        card.navToPlantUp();
      },
      [KEYMAP.NAV_PLANT_DOWN]: () => {
        card.navToPlantDown();
      },
      // [KEYMAP.NAV_LEFT]: () => {
      //   console.log(card.id + "left");
      // },
      // [KEYMAP.NAV_RIGHT]: () => {
      //   console.log(card.id + "right");
      // },
      [KEYMAP.BACKSPACE]: (ev) => {
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
      [KEYMAP.MOVE_UP]: () => {
        card.moveUp();
        restorePositon(ref.current);
      },
      [KEYMAP.MOVE_DOWN]: () => {
        card.moveDown();
        restorePositon(ref.current);
      },
      [KEYMAP.MOVE_LEFT]: () => {
        card.moveLevelUp();
        restorePositon(ref.current);
      },
      [KEYMAP.MOVE_RIGHT]: () => {
        card.moveLevelDown();
        restorePositon(ref.current);
      },
    },
    {
      enableOnTags: ["INPUT", "TEXTAREA"],
      filterPreventDefault: false,
      enabled: true,
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
      id={`card-header-${card.id}`}
      value={card.content}
      onChange={onContentChange}
    />
  );
});

export const CardTree = observer(
  ({ cards }: { cards: CardStore[]; parent?: CardStore }) => {
    if (!cards.length) {
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
