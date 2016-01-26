open Redaw.Internal_pervasives

let say fmt = ksprintf (printf "%s\n%!") fmt
let fail fmt = ksprintf failwith fmt

module Command_line = struct

  let sub_command ?man name ~doc ~term =
    let open Cmdliner in
    (term, Term.info name ~version:Redaw.Metadata.version ~doc ?man)

  let output_channel_and_format () =
    let open Cmdliner in
    Term.(
      pure begin fun output_format output_path ->
        let outchan, guess_format =
          match output_path with
          | Some "-" | None ->
            stdout, None
          | Some other ->
            let o = open_out other in
            at_exit (fun () -> close_out o);
            (o, (if Filename.check_suffix other ".json"
                 then Some `Json else None))
        in
        let format =
          match guess_format, output_format with
          | None, None
          | _, Some "show" -> `Show
          | Some `Json, None
          | _, Some "json" -> `Json
          | _, Some other -> fail "Can't understand output-format: %S" other
        in
        (outchan, format)
      end
      $ Arg.(
          info ["W"; "write-format"] ~docv:"FORMAT"
            ~doc:"Write format (for now `json` or `show`), \
                  default is to guess from `--output` or use `show`"
          |> opt (some string) None
          |> value
        )
      $ Arg.(
          info ["o"; "output"] ~docv:"PATH"
            ~doc:"Output stream (file or stdout)"
          |> opt (some string) None
          |> value
        )
    )

  let cmd_generate =
    let open Cmdliner in
    sub_command "generate"
      ~doc:"Generate dataset sepecifications"
      ~term: Term.(
          pure begin fun name (outchan, output_format) () ->
            let dataset =
              Redaw.Dataset.create ~name None in
            let content =
              match output_format with
              | `Show -> Redaw.Dataset.show dataset
              | `Json -> Redaw.Dataset.serialize dataset
            in
            output_string outchan content;
            ()
          end
          $ Arg.(
              info ["N"; "name"] ~docv:"NAME" ~doc:"Use the name $docv as name"
              |> opt string (Random.int (2 lsl 28) |> sprintf "redaw-%x")
              |> value
            )
          $ output_channel_and_format ()
        )

  let cmd_transform =
    let open Cmdliner in
    sub_command "transform"
      ~doc:"read/write dataset files/streams"
      ~term: Term.(
          pure begin fun input (outchan, output_format) () ->
            let inchan =
              match input with
              | Some "-" | None -> stdin
              | Some other ->
                let i = open_in other in at_exit (fun () -> close_in i); i
            in
            let yoj = Yojson.Safe.from_channel inchan in
            let dataset = Redaw.Dataset.of_json_exn yoj in
            let content =
              match output_format with
              | `Show -> Redaw.Dataset.show dataset
              | `Json -> Redaw.Dataset.serialize dataset
            in
            output_string outchan content;
            ()
          end
          $ Arg.(
              info ["i"; "input"] ~docv:"PATH"
                ~doc:"Input stream (file or `-` for stdin, the default)"
              |> opt (some string) None
              |> value
            )
          $ output_channel_and_format ()
        )

  let default_cmd =
    let open Cmdliner in
    let doc = "Simple Tool For Dealing With Datasets" in
    let man = [
      `S "AUTHORS";
      `P "Sebastien Mondet <seb@mondet.org>"; `Noblank;
      `S "BUGS";
      `P "Browse and report new issues at"; `Noblank;
      `P "<https://github.com/smondet/redaw>.";
    ] in
    sub_command "redaw" ~doc ~man
      ~term:Term.(ret (pure (`Help (`Plain, None))))

  let main () =
    let open Cmdliner in
    let cmds = [
      cmd_generate;
      cmd_transform;
    ] in
    match Term.eval_choice default_cmd cmds with
    | `Ok f ->
      begin try f ()
      with
      | Failure s -> eprintf "ERROR: %s\n%!" s; exit 2
      | e ->
        eprintf "ERROR: Exception %s" (Printexc.to_string e); exit 3
      end
    | `Error _ -> exit 1
    | `Version | `Help -> exit 0


end

let () = Command_line.main ()

                      (*    Redaw.Dataset.(
    create ~name:"World" (pointer_to "Dummy")
    |> name
  ) |> Printf.printf "Hello %s\n%!"
*)
