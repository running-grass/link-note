import { gql } from '@apollo/client';

const CardDtoFields = gql`
  fragment CardDtoFields on CardDto {
    id
    content
    cardType
    leftId
  }
`

const CardDtoRecursive = gql`
  ${CardDtoFields}
  fragment CardDtoRecursive on CardDto {
    ...CardDtoFields
    childrens {
      ...CardDtoFields
      childrens {
        ...CardDtoFields
        childrens {
          ...CardDtoFields
          childrens {
            ...CardDtoFields
            childrens {
              ...CardDtoFields
              childrens {
                ...CardDtoFields
                childrens {
                  ...CardDtoFields
                  childrens {
                    ...CardDtoFields
                    childrens {
                      ...CardDtoFields
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
`

export const QUERY_TOPIC = gql`
  query findTopic($title: String, $id: Int){
    ${CardDtoRecursive}
    topic(title: $title, id: $id) {
      id
      title
      cards {
        ...CardDtoRecursive
      }
    }
  }
`;

export const QUERY_TOPIC_LIST = gql`
  query findTopics($search: String, $limit: Int){
    topics (search: $search, limit: $limit) {
      id
      title
    }
  }
`;

export const MUTATION_CREATE_TOPIC = gql`
  mutation createTopic($title: String!){
    createTopic(title: $title) {
      id
      title
    }
  }
`

export const MUTATION_CREATE_CARD = gql`
  mutation createNewCard($belongId: Int!, $parentId: Int, $content: String, $cardType: CardType, $leftId: Int) {
    createNewCard(cardCreateInput: { 
        belongId: $belongId
        , parentId: $parentId
        , leftId: $leftId
        , content: $content
        , cardType: $cardType}) {
      id
      content
      cardType
    }
  }
`


export const MUTATION_UPDATE_CARDS = gql`
  mutation updateCards($cards: [CardInputDto!]!) {
    updateCards(cards: $cards)
  }
`



export const MUTATION_DELETE_CARD = gql`
  mutation deleteCard($cardId: Int!) {
    deleteCard(cardId: $cardId)
  }
`