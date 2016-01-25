
include Nonstd

module String = Sosa.Native_string

let ( // ) = Filename.concat

let failwithf fmt = ksprintf failwith fmt




module Json = struct
  type t = Yojson.Safe.json
  let to_string t = Yojson.Safe.pretty_to_string ~std:true t

  module Versioned = struct

    module type WITH_VERSIONED_SERIALIZATION = sig
      type t
      val to_json : t -> Yojson.Safe.json
      val of_json_exn : Yojson.Safe.json -> t
      val serialize : t -> string
      val deserialize_exn : string -> t
    end
    module Of_v0 (T: sig
        type t
        val to_yojson : t -> Yojson.Safe.json
        val of_yojson : Yojson.Safe.json -> [ `Error of string | `Ok of t ]
      end) : WITH_VERSIONED_SERIALIZATION with type t := T.t = struct
      type 'a versioned = V0 of 'a [@@deriving yojson]
      let to_json t =
        versioned_to_yojson T.to_yojson (V0 t)
      let serialize t =
        to_json t |> Yojson.Safe.pretty_to_string ~std:true
      let of_json_exn json : T.t =
        match versioned_of_yojson T.of_yojson json with
        | `Ok (V0 t) -> t
        | `Error str ->
          failwith (Printf.sprintf "deserialization error: %s" str)

      let deserialize_exn s =
        Yojson.Safe.from_string s |> of_json_exn

    end
  end
end
