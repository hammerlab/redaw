open Nonstd

module String = Sosa.Native_string
let ( // ) = Filename.concat

let failwithf fmt = ksprintf failwith fmt


type path = string
[@@deriving yojson]

type 'a sample =
  | Paired_end of 'a list * 'a list
[@@deriving yojson]

type 'a somatic =
  {normal : 'a sample; tumors : 'a sample list}
[@@deriving yojson]

type 'a rna =
  Rna of 'a sample
[@@deriving yojson]

type 'a dna =
  Dna of 'a somatic
[@@deriving yojson]

type host =
  | Uri of string
  | Local
[@@deriving yojson]

type location =
  | Static of host * path dna * path rna option
[@@deriving yojson]

type t = {
  name: string;
  location: location;
}
[@@deriving yojson]

let paired_end ~r1 ~r2 = Paired_end (r1, r2)
let static ~host ~name dna_sample rna_sample =
  {name; location = Static (host, dna_sample, rna_sample)}

let name t = t.name
