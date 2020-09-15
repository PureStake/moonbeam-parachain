# Requires
# cp ../target/release/moonbase-testnet ./
# cp ../target/release/wbuild/moonbase-runtime/moonbase_runtime.compact.wasm ./

FROM alpine
COPY moonbase-testnet /usr/local/bin/moonbase-testnet
RUN mkdir -p /moonbeam/runtime
COPY moonbase_runtime.compact.wasm /moonbeam/runtime/moonbase_runtime.compact.wasm

CMD /usr/local/bin/moonbase-testnet