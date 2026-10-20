import os from 'os';
import {Suspense} from 'react';
import {connection} from 'next/server';

type Data =
    | {ok: true; health: unknown; info: any}
    | {ok: false; error: string};

async function load(): Promise<Data> {
    await connection(); // opt into request-time rendering so BACKEND_URL is read at runtime
    const base = process.env.BACKEND_URL ?? 'http://backend:4000';
    try {
        const [h, i] = await Promise.all([
            fetch(`${base}/api/v1/health`, {cache: 'no-store'}),
            fetch(`${base}/api/v1/info`, {cache: 'no-store'}),
        ]);
        console.log(`Backend health: ${h.status}, info: ${i.status}`);
        return {ok: true, health: await h.json(), info: await i.json()};
    } catch (e) {
        console.log(`Backend unreachable: ${e instanceof Error ? e.message : String(e)}`);
        return {ok: false, error: e instanceof Error ? e.message : String(e)};
    }
}

const card = {background: '#1e293b', borderRadius: 12, padding: 20, marginBottom: 16} as const;
const pre = {margin: 0, fontSize: 13, overflowX: 'auto'} as const;

function Loading({title}: {title: string}) {
    return (
        <section style={card}>
            <h2>{title}</h2>
            <pre style={pre}>Loading...</pre>
        </section>
    );
}

async function BackendCard({promise}: {promise: Promise<Data>}) {
    const data = await promise;
    return (
        <section style={card}>
            <h2>Backend (NestJS) {data.ok ? '✅' : '❌'}</h2>
            <pre style={pre}>
                {data.ok
                    ? JSON.stringify({health: data.health, ...data.info.backend}, null, 2)
                    : data.error}
            </pre>
        </section>
    );
}

async function DatabaseCard({promise}: {promise: Promise<Data>}) {
    const data = await promise;
    const dbUp = data.ok && data.info?.database?.status === 'up';
    return (
        <section style={card}>
            <h2>Database (MySQL) {dbUp ? '✅' : '❌'}</h2>
            <pre style={pre}>
                {data.ok ? JSON.stringify(data.info.database, null, 2) : 'backend unreachable'}
            </pre>
        </section>
    );
}

export default function Page() {
    // Not awaited here: starts the request, children await it inside Suspense
    const dataPromise = load();

    return (
        <main style={{maxWidth: 720, margin: '0 auto', padding: 24}}>
            <h1>AWS Architect Demo</h1>

            <section style={card}>
                <h2>Frontend (Next.js)</h2>
                <pre style={pre}>
                    {JSON.stringify(
                        {environment: process.env.APP_ENV, container: os.hostname(), node: process.version},
                        null,
                        2,
                    )}
                </pre>
            </section>

            <Suspense fallback={<Loading title="Backend (NestJS)"/>}>
                <BackendCard promise={dataPromise}/>
            </Suspense>

            <Suspense fallback={<Loading title="Database (MySQL)"/>}>
                <DatabaseCard promise={dataPromise}/>
            </Suspense>
        </main>
    );
}