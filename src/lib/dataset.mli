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
    normal_dna : data list;
    tumor_dna : data list;
    normal_rna : data list;
    tumor_rna : data list;
  }
  and atom =
      File of (host * string)
    | Pointer_to of name
  and data =
    | Single_end of atom list
    | Paired_end of atom list * atom list
    | Somatic of somatic
    | Annotated of (metadata * data)
  and metadata =
      Url of string
    | Comment of string
    | Date of float
    | List of metadata list
    | Description of (string * metadata)
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
type atom

val pointer_to : string -> atom

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
