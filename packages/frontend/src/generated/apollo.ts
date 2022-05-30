import { ApolloClient, QueryOptions, SubscriptionOptions, MutationOptions } from '@apollo/client';
import gql from 'graphql-tag';
export type Maybe<T> = T | null;
export type InputMaybe<T> = Maybe<T>;
export type Exact<T extends { [key: string]: unknown }> = { [K in keyof T]: T[K] };
export type MakeOptional<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]?: Maybe<T[SubKey]> };
export type MakeMaybe<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]: Maybe<T[SubKey]> };
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: string;
  String: string;
  Boolean: boolean;
  Int: number;
  Float: number;
  /** A date-time string at UTC, such as 2019-12-03T09:54:33Z, compliant with the date-time format. */
  DateTime: any;
  /** A simple guid parser */
  GUID: any;
};

/** 实体查询中的通用排序字段 */
export enum BaseSort {
  CreateAt = 'createAt',
  Id = 'id',
  UpdatedAt = 'updatedAt'
}

export type CardCreateInput = {
  belongId: Scalars['GUID'];
  cardType?: InputMaybe<CardType>;
  content?: InputMaybe<Scalars['String']>;
  leftId?: InputMaybe<Scalars['GUID']>;
  parentId?: InputMaybe<Scalars['GUID']>;
};

/** 笔记卡片 */
export type CardDto = {
  __typename?: 'CardDto';
  cardType: CardType;
  childrens: Array<CardDto>;
  content: Scalars['String'];
  createAt: Scalars['DateTime'];
  id: Scalars['GUID'];
  leftId?: Maybe<Scalars['GUID']>;
  updateAt: Scalars['DateTime'];
};

export type CardInputDto = {
  cardType: CardType;
  childrens: Array<CardInputDto>;
  content: Scalars['String'];
  id: Scalars['GUID'];
};

/** Card内容的类型 */
export enum CardType {
  Inline = 'INLINE'
}

export type Mutation = {
  __typename?: 'Mutation';
  createNewCard: CardDto;
  createTopic: TopicDto;
  /** 删除指定的card */
  deleteCard: Scalars['Int'];
  registerUser: UserDto;
  /** 传入一个有序的CardDTO树，更新数据库中的leftId和parentId */
  updateCards: Scalars['Int'];
};


export type MutationCreateNewCardArgs = {
  cardCreateInput: CardCreateInput;
};


export type MutationCreateTopicArgs = {
  title: Scalars['String'];
};


export type MutationDeleteCardArgs = {
  cardId: Scalars['GUID'];
};


export type MutationRegisterUserArgs = {
  registerData: RegisterInput;
};


export type MutationUpdateCardsArgs = {
  cards: Array<CardInputDto>;
};

/** 所有查询、排序通用的排序 */
export enum Order {
  Asc = 'ASC',
  Desc = 'DESC'
}

export type Query = {
  __typename?: 'Query';
  currentUser: UserDto;
  topic?: Maybe<TopicDto>;
  /** 查询主题列表 */
  topics: Array<TopicDto>;
};


export type QueryTopicArgs = {
  id?: InputMaybe<Scalars['GUID']>;
  title?: InputMaybe<Scalars['String']>;
};


export type QueryTopicsArgs = {
  limit?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<Order>;
  search?: InputMaybe<Scalars['String']>;
  sort?: InputMaybe<BaseSort>;
};

export type RegisterInput = {
  email?: InputMaybe<Scalars['String']>;
  password: Scalars['String'];
  phone?: InputMaybe<Scalars['String']>;
  username: Scalars['String'];
};

/** 主题的DTO */
export type TopicDto = {
  __typename?: 'TopicDto';
  cards: Array<CardDto>;
  createAt: Scalars['DateTime'];
  id: Scalars['GUID'];
  title: Scalars['String'];
  updateAt: Scalars['DateTime'];
};

/** 用户信息 */
export type UserDto = {
  __typename?: 'UserDto';
  /** 用户的电子邮箱 */
  email?: Maybe<Scalars['String']>;
  id: Scalars['GUID'];
  /** 用户的手机号，不带国际区号 */
  phone?: Maybe<Scalars['String']>;
  /** 用户的用户名，不可修改 */
  username: Scalars['String'];
  /** 用户的工作空间列表 */
  workspaces: Array<WorkspaceDto>;
};

/** 用户的工作空间 */
export type WorkspaceDto = {
  __typename?: 'WorkspaceDto';
  /** 显示用名称 */
  displayName: Scalars['String'];
  id: Scalars['GUID'];
  /** 全局不重复的key */
  name: Scalars['String'];
};

export type CardDtoFieldsFragment = { __typename?: 'CardDto', id: any, content: string, cardType: CardType, leftId?: any | null };

export type CardDtoRecursiveFragment = { __typename?: 'CardDto', id: any, content: string, cardType: CardType, leftId?: any | null, childrens: Array<{ __typename?: 'CardDto', id: any, content: string, cardType: CardType, leftId?: any | null, childrens: Array<{ __typename?: 'CardDto', id: any, content: string, cardType: CardType, leftId?: any | null, childrens: Array<{ __typename?: 'CardDto', id: any, content: string, cardType: CardType, leftId?: any | null, childrens: Array<{ __typename?: 'CardDto', id: any, content: string, cardType: CardType, leftId?: any | null, childrens: Array<{ __typename?: 'CardDto', id: any, content: string, cardType: CardType, leftId?: any | null, childrens: Array<{ __typename?: 'CardDto', id: any, content: string, cardType: CardType, leftId?: any | null, childrens: Array<{ __typename?: 'CardDto', id: any, content: string, cardType: CardType, leftId?: any | null, childrens: Array<{ __typename?: 'CardDto', id: any, content: string, cardType: CardType, leftId?: any | null, childrens: Array<{ __typename?: 'CardDto', id: any, content: string, cardType: CardType, leftId?: any | null }> }> }> }> }> }> }> }> }> };

export type FindTopicQueryVariables = Exact<{
  title?: InputMaybe<Scalars['String']>;
  id?: InputMaybe<Scalars['GUID']>;
}>;


export type FindTopicQuery = { __typename?: 'Query', topic?: { __typename?: 'TopicDto', id: any, title: string, cards: Array<{ __typename?: 'CardDto', id: any, content: string, cardType: CardType, leftId?: any | null, childrens: Array<{ __typename?: 'CardDto', id: any, content: string, cardType: CardType, leftId?: any | null, childrens: Array<{ __typename?: 'CardDto', id: any, content: string, cardType: CardType, leftId?: any | null, childrens: Array<{ __typename?: 'CardDto', id: any, content: string, cardType: CardType, leftId?: any | null, childrens: Array<{ __typename?: 'CardDto', id: any, content: string, cardType: CardType, leftId?: any | null, childrens: Array<{ __typename?: 'CardDto', id: any, content: string, cardType: CardType, leftId?: any | null, childrens: Array<{ __typename?: 'CardDto', id: any, content: string, cardType: CardType, leftId?: any | null, childrens: Array<{ __typename?: 'CardDto', id: any, content: string, cardType: CardType, leftId?: any | null, childrens: Array<{ __typename?: 'CardDto', id: any, content: string, cardType: CardType, leftId?: any | null, childrens: Array<{ __typename?: 'CardDto', id: any, content: string, cardType: CardType, leftId?: any | null }> }> }> }> }> }> }> }> }> }> } | null };

export type FindTopicsQueryVariables = Exact<{
  search?: InputMaybe<Scalars['String']>;
  limit?: InputMaybe<Scalars['Int']>;
}>;


export type FindTopicsQuery = { __typename?: 'Query', topics: Array<{ __typename?: 'TopicDto', id: any, title: string }> };

export type CurrentUserQueryVariables = Exact<{ [key: string]: never; }>;


export type CurrentUserQuery = { __typename?: 'Query', currentUser: { __typename?: 'UserDto', id: any, username: string, phone?: string | null, email?: string | null, workspaces: Array<{ __typename?: 'WorkspaceDto', id: any, name: string, displayName: string }> } };

export type CreateTopicMutationVariables = Exact<{
  title: Scalars['String'];
}>;


export type CreateTopicMutation = { __typename?: 'Mutation', createTopic: { __typename?: 'TopicDto', id: any, title: string } };

export type CreateNewCardMutationVariables = Exact<{
  belongId: Scalars['GUID'];
  parentId?: InputMaybe<Scalars['GUID']>;
  content?: InputMaybe<Scalars['String']>;
  cardType?: InputMaybe<CardType>;
  leftId?: InputMaybe<Scalars['GUID']>;
}>;


export type CreateNewCardMutation = { __typename?: 'Mutation', createNewCard: { __typename?: 'CardDto', id: any, content: string, cardType: CardType } };

export type UpdateCardsMutationVariables = Exact<{
  cards: Array<CardInputDto> | CardInputDto;
}>;


export type UpdateCardsMutation = { __typename?: 'Mutation', updateCards: number };

export type DeleteCardMutationVariables = Exact<{
  cardId: Scalars['GUID'];
}>;


export type DeleteCardMutation = { __typename?: 'Mutation', deleteCard: number };

export type RegisterUserMutationVariables = Exact<{
  registerData: RegisterInput;
}>;


export type RegisterUserMutation = { __typename?: 'Mutation', registerUser: { __typename?: 'UserDto', id: any, username: string } };

export const CardDtoFieldsFragmentDoc = gql`
    fragment CardDtoFields on CardDto {
  id
  content
  cardType
  leftId
}
    `;
export const CardDtoRecursiveFragmentDoc = gql`
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
    ${CardDtoFieldsFragmentDoc}`;
export const FindTopicDocument = gql`
    query findTopic($title: String, $id: GUID) {
  topic(title: $title, id: $id) {
    id
    title
    cards {
      ...CardDtoRecursive
    }
  }
}
    ${CardDtoRecursiveFragmentDoc}`;
export const FindTopicsDocument = gql`
    query findTopics($search: String, $limit: Int) {
  topics(search: $search, limit: $limit) {
    id
    title
  }
}
    `;
export const CurrentUserDocument = gql`
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
    `;
export const CreateTopicDocument = gql`
    mutation createTopic($title: String!) {
  createTopic(title: $title) {
    id
    title
  }
}
    `;
export const CreateNewCardDocument = gql`
    mutation createNewCard($belongId: GUID!, $parentId: GUID, $content: String, $cardType: CardType, $leftId: GUID) {
  createNewCard(
    cardCreateInput: {belongId: $belongId, parentId: $parentId, leftId: $leftId, content: $content, cardType: $cardType}
  ) {
    id
    content
    cardType
  }
}
    `;
export const UpdateCardsDocument = gql`
    mutation updateCards($cards: [CardInputDto!]!) {
  updateCards(cards: $cards)
}
    `;
export const DeleteCardDocument = gql`
    mutation deleteCard($cardId: GUID!) {
  deleteCard(cardId: $cardId)
}
    `;
export const RegisterUserDocument = gql`
    mutation registerUser($registerData: RegisterInput!) {
  registerUser(registerData: $registerData) {
    id
    username
  }
}
    `;
export const getSdk = (client: ApolloClient<any>) => ({
      findTopicQuery(options: Partial<QueryOptions<FindTopicQueryVariables, FindTopicQuery>>) {
          return client.query<FindTopicQuery, FindTopicQueryVariables>({...options, query: FindTopicDocument})
      },
findTopicsQuery(options: Partial<QueryOptions<FindTopicsQueryVariables, FindTopicsQuery>>) {
          return client.query<FindTopicsQuery, FindTopicsQueryVariables>({...options, query: FindTopicsDocument})
      },
currentUserQuery(options: Partial<QueryOptions<CurrentUserQueryVariables, CurrentUserQuery>>) {
          return client.query<CurrentUserQuery, CurrentUserQueryVariables>({...options, query: CurrentUserDocument})
      },
createTopicMutation(options: Partial<MutationOptions<CreateTopicMutation, CreateTopicMutationVariables>>) {
          return client.mutate<CreateTopicMutation, CreateTopicMutationVariables>({...options, mutation: CreateTopicDocument})
      },
createNewCardMutation(options: Partial<MutationOptions<CreateNewCardMutation, CreateNewCardMutationVariables>>) {
          return client.mutate<CreateNewCardMutation, CreateNewCardMutationVariables>({...options, mutation: CreateNewCardDocument})
      },
updateCardsMutation(options: Partial<MutationOptions<UpdateCardsMutation, UpdateCardsMutationVariables>>) {
          return client.mutate<UpdateCardsMutation, UpdateCardsMutationVariables>({...options, mutation: UpdateCardsDocument})
      },
deleteCardMutation(options: Partial<MutationOptions<DeleteCardMutation, DeleteCardMutationVariables>>) {
          return client.mutate<DeleteCardMutation, DeleteCardMutationVariables>({...options, mutation: DeleteCardDocument})
      },
registerUserMutation(options: Partial<MutationOptions<RegisterUserMutation, RegisterUserMutationVariables>>) {
          return client.mutate<RegisterUserMutation, RegisterUserMutationVariables>({...options, mutation: RegisterUserDocument})
      }
    });
    export type SdkType = ReturnType<typeof getSdk>
