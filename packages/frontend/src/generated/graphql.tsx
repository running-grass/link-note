import { gql } from '@apollo/client';
import * as Apollo from '@apollo/client';
export type Maybe<T> = T | null;
export type InputMaybe<T> = Maybe<T>;
export type Exact<T extends { [key: string]: unknown }> = { [K in keyof T]: T[K] };
export type MakeOptional<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]?: Maybe<T[SubKey]> };
export type MakeMaybe<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]: Maybe<T[SubKey]> };
const defaultOptions = {} as const;
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
  leftId?: InputMaybe<Scalars['Int']>;
  parentId?: InputMaybe<Scalars['Int']>;
};

export type CardDto = {
  __typename?: 'CardDto';
  cardType: CardType;
  childrens: Array<CardDto>;
  content: Scalars['String'];
  createAt: Scalars['DateTime'];
  id: Scalars['Int'];
  leftId?: Maybe<Scalars['Int']>;
  updateAt: Scalars['DateTime'];
};

export type CardInputDto = {
  cardType: CardType;
  childrens: Array<CardInputDto>;
  content: Scalars['String'];
  id: Scalars['Int'];
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
  cardId: Scalars['Int'];
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

export type RegisterInput = {
  email: Scalars['String'];
  password: Scalars['String'];
  phone: Scalars['String'];
  username: Scalars['String'];
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

/** 用户信息 */
export type UserDto = {
  __typename?: 'UserDto';
  email?: Maybe<Scalars['String']>;
  id: Scalars['Float'];
  phone?: Maybe<Scalars['String']>;
  username: Scalars['String'];
};

export type CardDtoFieldsFragment = { __typename?: 'CardDto', id: number, content: string, cardType: CardType, leftId?: number | null };

export type CardDtoRecursiveFragment = { __typename?: 'CardDto', id: number, content: string, cardType: CardType, leftId?: number | null, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, leftId?: number | null, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, leftId?: number | null, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, leftId?: number | null, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, leftId?: number | null, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, leftId?: number | null, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, leftId?: number | null, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, leftId?: number | null, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, leftId?: number | null, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, leftId?: number | null }> }> }> }> }> }> }> }> }> };

export type FindTopicQueryVariables = Exact<{
  title?: InputMaybe<Scalars['String']>;
  id?: InputMaybe<Scalars['Int']>;
}>;


export type FindTopicQuery = { __typename?: 'Query', topic?: { __typename?: 'TopicDto', id: number, title: string, cards: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, leftId?: number | null, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, leftId?: number | null, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, leftId?: number | null, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, leftId?: number | null, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, leftId?: number | null, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, leftId?: number | null, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, leftId?: number | null, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, leftId?: number | null, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, leftId?: number | null, childrens: Array<{ __typename?: 'CardDto', id: number, content: string, cardType: CardType, leftId?: number | null }> }> }> }> }> }> }> }> }> }> } | null };

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
  leftId?: InputMaybe<Scalars['Int']>;
}>;


export type CreateNewCardMutation = { __typename?: 'Mutation', createNewCard: { __typename?: 'CardDto', id: number, content: string, cardType: CardType } };

export type UpdateCardsMutationVariables = Exact<{
  cards: Array<CardInputDto> | CardInputDto;
}>;


export type UpdateCardsMutation = { __typename?: 'Mutation', updateCards: number };

export type DeleteCardMutationVariables = Exact<{
  cardId: Scalars['Int'];
}>;


export type DeleteCardMutation = { __typename?: 'Mutation', deleteCard: number };

export type RegisterUserMutationVariables = Exact<{
  registerData: RegisterInput;
}>;


export type RegisterUserMutation = { __typename?: 'Mutation', registerUser: { __typename?: 'UserDto', id: number, username: string } };

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

/**
 * __useFindTopicQuery__
 *
 * To run a query within a React component, call `useFindTopicQuery` and pass it any options that fit your needs.
 * When your component renders, `useFindTopicQuery` returns an object from Apollo Client that contains loading, error, and data properties
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useFindTopicQuery({
 *   variables: {
 *      title: // value for 'title'
 *      id: // value for 'id'
 *   },
 * });
 */
export function useFindTopicQuery(baseOptions?: Apollo.QueryHookOptions<FindTopicQuery, FindTopicQueryVariables>) {
        const options = {...defaultOptions, ...baseOptions}
        return Apollo.useQuery<FindTopicQuery, FindTopicQueryVariables>(FindTopicDocument, options);
      }
export function useFindTopicLazyQuery(baseOptions?: Apollo.LazyQueryHookOptions<FindTopicQuery, FindTopicQueryVariables>) {
          const options = {...defaultOptions, ...baseOptions}
          return Apollo.useLazyQuery<FindTopicQuery, FindTopicQueryVariables>(FindTopicDocument, options);
        }
export type FindTopicQueryHookResult = ReturnType<typeof useFindTopicQuery>;
export type FindTopicLazyQueryHookResult = ReturnType<typeof useFindTopicLazyQuery>;
export type FindTopicQueryResult = Apollo.QueryResult<FindTopicQuery, FindTopicQueryVariables>;
export const FindTopicsDocument = gql`
    query findTopics($search: String, $limit: Int) {
  topics(search: $search, limit: $limit) {
    id
    title
  }
}
    `;

/**
 * __useFindTopicsQuery__
 *
 * To run a query within a React component, call `useFindTopicsQuery` and pass it any options that fit your needs.
 * When your component renders, `useFindTopicsQuery` returns an object from Apollo Client that contains loading, error, and data properties
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useFindTopicsQuery({
 *   variables: {
 *      search: // value for 'search'
 *      limit: // value for 'limit'
 *   },
 * });
 */
export function useFindTopicsQuery(baseOptions?: Apollo.QueryHookOptions<FindTopicsQuery, FindTopicsQueryVariables>) {
        const options = {...defaultOptions, ...baseOptions}
        return Apollo.useQuery<FindTopicsQuery, FindTopicsQueryVariables>(FindTopicsDocument, options);
      }
export function useFindTopicsLazyQuery(baseOptions?: Apollo.LazyQueryHookOptions<FindTopicsQuery, FindTopicsQueryVariables>) {
          const options = {...defaultOptions, ...baseOptions}
          return Apollo.useLazyQuery<FindTopicsQuery, FindTopicsQueryVariables>(FindTopicsDocument, options);
        }
export type FindTopicsQueryHookResult = ReturnType<typeof useFindTopicsQuery>;
export type FindTopicsLazyQueryHookResult = ReturnType<typeof useFindTopicsLazyQuery>;
export type FindTopicsQueryResult = Apollo.QueryResult<FindTopicsQuery, FindTopicsQueryVariables>;
export const CreateTopicDocument = gql`
    mutation createTopic($title: String!) {
  createTopic(title: $title) {
    id
    title
  }
}
    `;
export type CreateTopicMutationFn = Apollo.MutationFunction<CreateTopicMutation, CreateTopicMutationVariables>;

/**
 * __useCreateTopicMutation__
 *
 * To run a mutation, you first call `useCreateTopicMutation` within a React component and pass it any options that fit your needs.
 * When your component renders, `useCreateTopicMutation` returns a tuple that includes:
 * - A mutate function that you can call at any time to execute the mutation
 * - An object with fields that represent the current status of the mutation's execution
 *
 * @param baseOptions options that will be passed into the mutation, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options-2;
 *
 * @example
 * const [createTopicMutation, { data, loading, error }] = useCreateTopicMutation({
 *   variables: {
 *      title: // value for 'title'
 *   },
 * });
 */
export function useCreateTopicMutation(baseOptions?: Apollo.MutationHookOptions<CreateTopicMutation, CreateTopicMutationVariables>) {
        const options = {...defaultOptions, ...baseOptions}
        return Apollo.useMutation<CreateTopicMutation, CreateTopicMutationVariables>(CreateTopicDocument, options);
      }
export type CreateTopicMutationHookResult = ReturnType<typeof useCreateTopicMutation>;
export type CreateTopicMutationResult = Apollo.MutationResult<CreateTopicMutation>;
export type CreateTopicMutationOptions = Apollo.BaseMutationOptions<CreateTopicMutation, CreateTopicMutationVariables>;
export const CreateNewCardDocument = gql`
    mutation createNewCard($belongId: Int!, $parentId: Int, $content: String, $cardType: CardType, $leftId: Int) {
  createNewCard(
    cardCreateInput: {belongId: $belongId, parentId: $parentId, leftId: $leftId, content: $content, cardType: $cardType}
  ) {
    id
    content
    cardType
  }
}
    `;
export type CreateNewCardMutationFn = Apollo.MutationFunction<CreateNewCardMutation, CreateNewCardMutationVariables>;

/**
 * __useCreateNewCardMutation__
 *
 * To run a mutation, you first call `useCreateNewCardMutation` within a React component and pass it any options that fit your needs.
 * When your component renders, `useCreateNewCardMutation` returns a tuple that includes:
 * - A mutate function that you can call at any time to execute the mutation
 * - An object with fields that represent the current status of the mutation's execution
 *
 * @param baseOptions options that will be passed into the mutation, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options-2;
 *
 * @example
 * const [createNewCardMutation, { data, loading, error }] = useCreateNewCardMutation({
 *   variables: {
 *      belongId: // value for 'belongId'
 *      parentId: // value for 'parentId'
 *      content: // value for 'content'
 *      cardType: // value for 'cardType'
 *      leftId: // value for 'leftId'
 *   },
 * });
 */
export function useCreateNewCardMutation(baseOptions?: Apollo.MutationHookOptions<CreateNewCardMutation, CreateNewCardMutationVariables>) {
        const options = {...defaultOptions, ...baseOptions}
        return Apollo.useMutation<CreateNewCardMutation, CreateNewCardMutationVariables>(CreateNewCardDocument, options);
      }
export type CreateNewCardMutationHookResult = ReturnType<typeof useCreateNewCardMutation>;
export type CreateNewCardMutationResult = Apollo.MutationResult<CreateNewCardMutation>;
export type CreateNewCardMutationOptions = Apollo.BaseMutationOptions<CreateNewCardMutation, CreateNewCardMutationVariables>;
export const UpdateCardsDocument = gql`
    mutation updateCards($cards: [CardInputDto!]!) {
  updateCards(cards: $cards)
}
    `;
export type UpdateCardsMutationFn = Apollo.MutationFunction<UpdateCardsMutation, UpdateCardsMutationVariables>;

/**
 * __useUpdateCardsMutation__
 *
 * To run a mutation, you first call `useUpdateCardsMutation` within a React component and pass it any options that fit your needs.
 * When your component renders, `useUpdateCardsMutation` returns a tuple that includes:
 * - A mutate function that you can call at any time to execute the mutation
 * - An object with fields that represent the current status of the mutation's execution
 *
 * @param baseOptions options that will be passed into the mutation, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options-2;
 *
 * @example
 * const [updateCardsMutation, { data, loading, error }] = useUpdateCardsMutation({
 *   variables: {
 *      cards: // value for 'cards'
 *   },
 * });
 */
export function useUpdateCardsMutation(baseOptions?: Apollo.MutationHookOptions<UpdateCardsMutation, UpdateCardsMutationVariables>) {
        const options = {...defaultOptions, ...baseOptions}
        return Apollo.useMutation<UpdateCardsMutation, UpdateCardsMutationVariables>(UpdateCardsDocument, options);
      }
export type UpdateCardsMutationHookResult = ReturnType<typeof useUpdateCardsMutation>;
export type UpdateCardsMutationResult = Apollo.MutationResult<UpdateCardsMutation>;
export type UpdateCardsMutationOptions = Apollo.BaseMutationOptions<UpdateCardsMutation, UpdateCardsMutationVariables>;
export const DeleteCardDocument = gql`
    mutation deleteCard($cardId: Int!) {
  deleteCard(cardId: $cardId)
}
    `;
export type DeleteCardMutationFn = Apollo.MutationFunction<DeleteCardMutation, DeleteCardMutationVariables>;

/**
 * __useDeleteCardMutation__
 *
 * To run a mutation, you first call `useDeleteCardMutation` within a React component and pass it any options that fit your needs.
 * When your component renders, `useDeleteCardMutation` returns a tuple that includes:
 * - A mutate function that you can call at any time to execute the mutation
 * - An object with fields that represent the current status of the mutation's execution
 *
 * @param baseOptions options that will be passed into the mutation, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options-2;
 *
 * @example
 * const [deleteCardMutation, { data, loading, error }] = useDeleteCardMutation({
 *   variables: {
 *      cardId: // value for 'cardId'
 *   },
 * });
 */
export function useDeleteCardMutation(baseOptions?: Apollo.MutationHookOptions<DeleteCardMutation, DeleteCardMutationVariables>) {
        const options = {...defaultOptions, ...baseOptions}
        return Apollo.useMutation<DeleteCardMutation, DeleteCardMutationVariables>(DeleteCardDocument, options);
      }
export type DeleteCardMutationHookResult = ReturnType<typeof useDeleteCardMutation>;
export type DeleteCardMutationResult = Apollo.MutationResult<DeleteCardMutation>;
export type DeleteCardMutationOptions = Apollo.BaseMutationOptions<DeleteCardMutation, DeleteCardMutationVariables>;
export const RegisterUserDocument = gql`
    mutation registerUser($registerData: RegisterInput!) {
  registerUser(registerData: $registerData) {
    id
    username
  }
}
    `;
export type RegisterUserMutationFn = Apollo.MutationFunction<RegisterUserMutation, RegisterUserMutationVariables>;

/**
 * __useRegisterUserMutation__
 *
 * To run a mutation, you first call `useRegisterUserMutation` within a React component and pass it any options that fit your needs.
 * When your component renders, `useRegisterUserMutation` returns a tuple that includes:
 * - A mutate function that you can call at any time to execute the mutation
 * - An object with fields that represent the current status of the mutation's execution
 *
 * @param baseOptions options that will be passed into the mutation, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options-2;
 *
 * @example
 * const [registerUserMutation, { data, loading, error }] = useRegisterUserMutation({
 *   variables: {
 *      registerData: // value for 'registerData'
 *   },
 * });
 */
export function useRegisterUserMutation(baseOptions?: Apollo.MutationHookOptions<RegisterUserMutation, RegisterUserMutationVariables>) {
        const options = {...defaultOptions, ...baseOptions}
        return Apollo.useMutation<RegisterUserMutation, RegisterUserMutationVariables>(RegisterUserDocument, options);
      }
export type RegisterUserMutationHookResult = ReturnType<typeof useRegisterUserMutation>;
export type RegisterUserMutationResult = Apollo.MutationResult<RegisterUserMutation>;
export type RegisterUserMutationOptions = Apollo.BaseMutationOptions<RegisterUserMutation, RegisterUserMutationVariables>;