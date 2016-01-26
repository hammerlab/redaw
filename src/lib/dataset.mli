(** Definition of the dataset data-type. *)

(** In progress definition of a set of file paths and URLs that have
    some semantic relationship.

    The serialization to JSON should be backwards compatible hence the
    [V0] mentions that you'll see here and there.

*)

(** The first version of the format (exposed for documentation purposes). *)
module V0 : sig
  type name = string
  type host = Uri of string | Local
  type somatic = {
    normal : data list;
    tumor : data list;
    rna : data list;
  }
  and data =
      Located of host * data
    | Pointer_to of name
    | File of string
    | Single_end of data list
    | Paired_end of data list * data list
    | Somatic of somatic
  type metadata =
      Url of string
    | Comment of string
    | Date of float
    | List of metadata list
    | Description of (string * metadata) list
  type t = {
    name : string;
    content : data option;
    metadata : metadata option;
  }
end



type t
(** Abstract type representing datasets. *)

(** {3 Constructors} *)

type metadata
type data

val pointer_to : string -> data

val create :
  name:string -> ?metadata:metadata -> data option -> t

(** {3 Accessors} *)

val name : t -> string

(** {3 Display-friendly Functions} *)

val show : t -> string
val pp : Format.formatter -> t -> unit

(** {3 Serialization} *)

val to_json : t -> Yojson.Safe.json
val of_json_exn : Yojson.Safe.json -> t
val serialize : t -> string
val deserialize_exn : string -> t

(** {3 Emergency Low-level Access} *)

val of_v0: V0.t -> t
val to_v0: t -> V0.t
