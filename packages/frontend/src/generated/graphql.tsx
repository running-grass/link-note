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
};

export type Mutation = {
  __typename?: 'Mutation';
  createTopic: TopicDto;
};


export type MutationCreateTopicArgs = {
  title: Scalars['String'];
};

export enum NodeDtoSort {
  CreateDate = 'createDate',
  UpdateDate = 'updateDate'
}

export enum Order {
  Asc = 'ASC',
  Desc = 'DESC'
}

export type Query = {
  __typename?: 'Query';
  topic: TopicDto;
  /** 查询主题列表 */
  topics: Array<TopicDto>;
};


export type QueryTopicArgs = {
  id: Scalars['Float'];
};


export type QueryTopicsArgs = {
  limit?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<Order>;
  search?: InputMaybe<Scalars['String']>;
  sort?: InputMaybe<NodeDtoSort>;
};

/** 主题的DTO */
export type TopicDto = {
  __typename?: 'TopicDto';
  id: Scalars['Int'];
  title: Scalars['String'];
};

export type FindTopicQueryVariables = Exact<{ [key: string]: never; }>;


export type FindTopicQuery = { __typename?: 'Query', topic: { __typename?: 'TopicDto', id: number, title: string } };

export type FindTopicsQueryVariables = Exact<{
  search?: InputMaybe<Scalars['String']>;
  limit?: InputMaybe<Scalars['Int']>;
}>;


export type FindTopicsQuery = { __typename?: 'Query', topics: Array<{ __typename?: 'TopicDto', id: number, title: string }> };

export type CreateTopicMutationVariables = Exact<{
  title: Scalars['String'];
}>;


export type CreateTopicMutation = { __typename?: 'Mutation', createTopic: { __typename?: 'TopicDto', id: number, title: string } };


export const FindTopicDocument = gql`
    query findTopic {
  topic(id: 1) {
    id
    title
  }
}
    `;

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