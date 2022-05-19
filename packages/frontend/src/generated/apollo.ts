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
};

/** 实体查询中的通用排序字段 */
export enum BaseSort {
  CreateAt = 'createAt',
  Id = 'id',
  UpdatedAt = 'updatedAt'
}

export type CardCreateInput = {
  belongId: Scalars['Int'];
  cardType?: InputMaybe<CardType>;
  content?: InputMaybe<Scalars['String']>;
  parentId?: InputMaybe<Scalars['Int']>;
};

export type CardDto = {
  __typename?: 'CardDto';
  cardType: CardType;
  childrens: Array<CardDto>;
  content: Scalars['String'];
  createAt: Scalars['DateTime'];
  id: Scalars['Int'];
  updateAt: Scalars['DateTime'];
};

/** Card内容的类型 */
export enum CardType {
  Inline = 'INLINE'
}

export type Mutation = {
  __typename?: 'Mutation';
  createNewCard: CardDto;
  createTopic: TopicDto;
};


export type MutationCreateNewCardArgs = {
  cardCreateInput: CardCreateInput;
};


export type MutationCreateTopicArgs = {
  title: Scalars['String'];
};

/** 所有查询、排序通用的排序 */
export enum Order {
  Asc = 'ASC',
  Desc = 'DESC'
}

export type Query = {
  __typename?: 'Query';
  topic?: Maybe<TopicDto>;
  /** 查询主题列表 */
  topics: Array<TopicDto>;
};


export type QueryTopicArgs = {
  id?: InputMaybe<Scalars['Int']>;
  title?: InputMaybe<Scalars['String']>;
};


export type QueryTopicsArgs = {
  limit?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<Order>;
  search?: InputMaybe<Scalars['String']>;
  sort?: InputMaybe<BaseSort>;
};

/** 主题的DTO */
export type TopicDto = {
  __typename?: 'TopicDto';
  cards: Array<CardDto>;
  createAt: Scalars['DateTime'];
  id: Scalars['Int'];
  title: Scalars['String'];
  updateAt: Scalars['DateTime'];
};

export type CardDtoFieldsFragment = { __typename?: 'CardDto', id: number, content: string, cardType: CardType };

export type CardDtoRecursiveFragment = { __typename?: 'CardDto', id: number, content: string, cardType: CardType, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType }> }> }> }> }> }> }> }> }> };

export type FindTopicQueryVariables = Exact<{
  title?: InputMaybe<Scalars['String']>;
  id?: InputMaybe<Scalars['Int']>;
}>;


export type FindTopicQuery = { __typename?: 'Query', topic?: { __typename?: 'TopicDto', id: number, title: string, cards: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType }> }> }> }> }> }> }> }> }> }> } | null };

export type FindTopicsQueryVariables = Exact<{
  search?: InputMaybe<Scalars['String']>;
  limit?: InputMaybe<Scalars['Int']>;
}>;


export type FindTopicsQuery = { __typename?: 'Query', topics: Array<{ __typename?: 'TopicDto', id: number, title: string }> };

export type CreateTopicMutationVariables = Exact<{
  title: Scalars['String'];
}>;


export type CreateTopicMutation = { __typename?: 'Mutation', createTopic: { __typename?: 'TopicDto', id: number, title: string } };

export type CreateNewCardMutationVariables = Exact<{
  belongId: Scalars['Int'];
  parentId?: InputMaybe<Scalars['Int']>;
  content?: InputMaybe<Scalars['String']>;
  cardType?: InputMaybe<CardType>;
}>;


export type CreateNewCardMutation = { __typename?: 'Mutation', createNewCard: { __typename?: 'CardDto', id: number, content: string } };

export const CardDtoFieldsFragmentDoc = gql`
    fragment CardDtoFields on CardDto {
  id
  content
  cardType
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
    query findTopic($title: String, $id: Int) {
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
export const CreateTopicDocument = gql`
    mutation createTopic($title: String!) {
  createTopic(title: $title) {
    id
    title
  }
}
    `;
export const CreateNewCardDocument = gql`
    mutation createNewCard($belongId: Int!, $parentId: Int, $content: String, $cardType: CardType) {
  createNewCard(
    cardCreateInput: {belongId: $belongId, parentId: $parentId, content: $content, cardType: $cardType}
  ) {
    id
    content
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
createTopicMutation(options: Partial<MutationOptions<CreateTopicMutation, CreateTopicMutationVariables>>) {
          return client.mutate<CreateTopicMutation, CreateTopicMutationVariables>({...options, mutation: CreateTopicDocument})
      },
createNewCardMutation(options: Partial<MutationOptions<CreateNewCardMutation, CreateNewCardMutationVariables>>) {
          return client.mutate<CreateNewCardMutation, CreateNewCardMutationVariables>({...options, mutation: CreateNewCardDocument})
      }
    });
    export type SdkType = ReturnType<typeof getSdk>
