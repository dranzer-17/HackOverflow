import { NextRequest, NextResponse } from "next/server";

const BACKEND_URL = process.env.BACKEND_URL || "http://localhost:8000";

async function handler(
  req: NextRequest,
  { params }: { params: Promise<{ path?: string[] }> }
) {
  const { path } = await params;
  const pathname = path ? path.join("/") : "";
  const search = req.nextUrl.search;
  const url = `${BACKEND_URL}/${pathname}${search}`;

  const headers = new Headers(req.headers);
  headers.delete("host");

  const response = await fetch(url, {
    method: req.method,
    headers,
    body: req.method !== "GET" && req.method !== "HEAD" ? req.body : undefined,
    duplex: "half",
  } as RequestInit);

  const resHeaders = new Headers(response.headers);
  resHeaders.delete("content-encoding");

  return new NextResponse(response.body, {
    status: response.status,
    headers: resHeaders,
  });
}

export const GET = handler;
export const POST = handler;
export const PUT = handler;
export const PATCH = handler;
export const DELETE = handler;
export const OPTIONS = handler;
