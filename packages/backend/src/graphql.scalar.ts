import { CustomScalar, Scalar } from "@nestjs/graphql";
import { GraphQLScalarType, Kind } from "graphql";
import { guidLength } from "./util/common";
import { Guid } from "./util/type";

function validate(guid: unknown): Guid | never {
  if (typeof guid !== "string" || guid.length !== guidLength) {
    throw new Error("invalid guid");
  }

  return guid;
}

export const GUIDScalar = new GraphQLScalarType({
  name: 'GUID',
  description: 'A simple guid parser',
  serialize: (value) => validate(value),
  parseValue: (value) => validate(value),
  parseLiteral: (ast) => {
    if (ast.kind == Kind.STRING) {
      return validate(ast.value)
    }

    return null
  }
})


// @Scalar('GUID', (type) => GUIScalar)
// export class GUIScalar implements CustomScalar<string, Guid> {
//   description?: string = "Guid的graphql标量"

//   serialize(value: Guid): string {
//     return validate(value)
//   }


//   parseValue(value: string): Guid {
//     return validate(value)
//   }


//   parseLiteral(ast): Guid | null {
//     if (ast.kind == Kind.STRING) {
//       return validate(ast.value)
//     }

//     return null
//   }
// }