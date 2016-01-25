open Internal_pervasives

module V0 = struct
  type name = string [@@deriving yojson]

  type host =
    | Uri of string
    | Local
    [@@deriving yojson]

  type somatic =
    { normal : data list;
      tumor : data list;
      rna : data list; }
  and data =
    | Located of host * data
    | Pointer_to of name
    | File of string
    | Single_end of data list
    | Paired_end of data list * data list
    | Somatic of data list * data list * data list
    [@@deriving yojson]

  type metadata =
    | Url of string
    | Comment of string
    | Date of float
    | List of metadata list
    | Description of (string * metadata) list
    [@@deriving yojson]

  type t = {
    name: string;
    content: data;
    metadata: metadata option;
  } [@@deriving yojson]
end

open V0

let pointer_to name = Pointer_to name

let create ~name ?metadata content = {name; metadata; content}

(*
let dna ~normal ~tumors = Dna {normal; tumors}
let paired_end ~r1 ~r2 = Paired_end (r1, r2)
let static ?(host = Local) ~name dna_sample rna_sample =
  {name; location = Static (host, dna_sample, rna_sample)}
*)

let name t = t.name

include Json.Versioned.Of_v0(V0)
