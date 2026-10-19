set pagination off
set confirm off
set breakpoint pending on
set debuginfod enabled off

# Record which connection becomes unusable and the path that led there.
break tds_set_state if state == TDS_DEAD
commands
  silent
  printf "\n--- FreeTDS transition to TDS_DEAD ---\n"
  print tds
  print tds->state
  bt 12
  continue
end

# The previous trace crashed while calling this error handler.
break tdserror if msgno == 20006
commands
  silent
  printf "\n--- FreeTDS write error, before callback ---\n"
  print tds
  print tds_ctx
  if tds_ctx != 0
    print *tds_ctx
    print tds_ctx->err_handler
    info symbol tds_ctx->err_handler
  end
  bt 12
  continue
end

break tds_free_context
commands
  silent
  printf "\n--- FreeTDS context being freed ---\n"
  print context
  if context != 0
    print context->err_handler
  end
  bt 8
  continue
end

break tds_free_socket
commands
  silent
  printf "\n--- FreeTDS socket being freed ---\n"
  print tds
  bt 8
  continue
end

run
info sharedlibrary
thread apply all bt full
info registers
