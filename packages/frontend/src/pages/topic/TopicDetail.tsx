import { useParams } from "react-router-dom";
import { useFindTopicQuery } from "../../generated/graphql";

export default function TopicDetail() {

    const { title } = useParams();

    const {data} = useFindTopicQuery({variables: {
        title
    }});
    return <div>i am a topic: { data?.topic?.id }</div>
}