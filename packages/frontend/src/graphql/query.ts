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
  query findTopic($title: String, $id: GUID){
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


export const QUERY_CURREN_USER = gql`
  query currentUser {
    currentUser {
      id
      username
      phone
      email
      workspaces {
        id
        name
        displayName
      }
    }
  }
`

export const MUTATION_CREATE_TOPIC = gql`
  mutation createTopic($title: String!){
    createTopic(title: $title) {
      id
      title
    }
  }
`

export const MUTATION_CREATE_CARD = gql`
  mutation createNewCard($belongId: GUID!, $parentId: GUID, $content: String, $cardType: CardType, $leftId: GUID) {
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
  mutation deleteCard($cardId: GUID!) {
    deleteCard(cardId: $cardId)
  }
`

export const MUTATION_REGISTER_USER = gql`
  mutation registerUser($registerData: RegisterInput! ) 
  {
    registerUser(registerData: $registerData) {
      id
      username
    }
  }
`

// export const MUTATION_LOGIN = gql`
//   mutation login($username: String!, $password: String! ) 
//   {
//     login(username: $username, password: $password) {
//       id
//       username
//     }
//   }
// `