open Redaw.Internal_pervasives

let say fmt = ksprintf (printf "%s\n%!") fmt
let fail fmt = ksprintf failwith fmt


let () =
  let open Cmdliner in
  let version = Redaw.Metadata.version in
  let sub_command ~info ~term = (term, info) in
  let cmd_generate =
    sub_command
      ~info:(Term.info "generate" ~version ~man:[]
               ~doc:"Generate dataset sepecifications")
      ~term: Term.(
          pure begin fun name output_format output () ->
            let dataset =
              Redaw.Dataset.create ~name None in
            let outchan, guess_format =
              match output with
              | Some "-" | None ->
                stdout, None
              | Some other ->
                let o = open_out other in
                at_exit (fun () -> close_out o);
                (o, (if Filename.check_suffix other ".json"
                     then Some `Json else None))
            in
            let content =
              match guess_format, output_format with
              | None, None
              | _, Some "show" -> Redaw.Dataset.show dataset
              | Some `Json, None
              | _, Some "json" -> Redaw.Dataset.serialize dataset
              | _, Some other -> fail "Can't understand output-format: %S" other
            in
            output_string outchan content;
            ()
          end
          $ Arg.(
              info ["N"; "name"] ~docv:"NAME" ~doc:"Use the name $docv as name"
              |> opt string (Random.int (2 lsl 28) |> sprintf "redaw-%x")
              |> value
            )
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
        ) in

  let cmd_build_form_patterns =
    sub_command
      ~info:(Term.info "transform" ~version ~man:[]
               ~doc:"read/write dataset files/streams")
      ~term: Term.(
          pure begin fun input output_format output () ->
            let inchan =
              match input with
              | Some "-" | None -> stdin
              | Some other ->
                let i = open_in other in at_exit (fun () -> close_in i); i
            in
            let yoj = Yojson.Safe.from_channel inchan in
            let dataset = Redaw.Dataset.of_json_exn yoj in
            let outchan, guess_format =
              match output with
              | Some "-" | None ->
                stdout, None
              | Some other ->
                let o = open_out other in
                at_exit (fun () -> close_out o);
                (o, (if Filename.check_suffix other ".json"
                     then Some `Json else None))
            in
            let content =
              match guess_format, output_format with
              | None, None
              | _, Some "show" -> Redaw.Dataset.show dataset
              | Some `Json, None
              | _, Some "json" -> Redaw.Dataset.serialize dataset
              | _, Some other -> fail "Can't understand output-format: %S" other
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
        ) in
  let default_cmd =
    let doc = "Simple Tool For Dealing With Datasets" in
    let man = [
      `S "AUTHORS";
      `P "Sebastien Mondet <seb@mondet.org>"; `Noblank;
      `S "BUGS";
      `P "Browse and report new issues at"; `Noblank;
      `P "<https://github.com/smondet/redaw>.";
    ] in
    sub_command
      ~term:Term.(ret (pure (`Help (`Plain, None))))
      ~info:(Term.info "redaw" ~version ~doc ~man) in
  let cmds = [
    cmd_generate;
    cmd_build_form_patterns;
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

                      (*    Redaw.Dataset.(
    create ~name:"World" (pointer_to "Dummy")
    |> name
  ) |> Printf.printf "Hello %s\n%!"
*)
