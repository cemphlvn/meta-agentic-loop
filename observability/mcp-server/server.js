#!/usr/bin/env node
/**
 * Agent Trace MCP Server
 *
 * Provides tools for querying OTel-compatible agent traces.
 *
 * Tools:
 *   - trace_lineage: Show agent spawn hierarchy for a trace
 *   - trace_runs: List completed agent runs
 *   - trace_stats: Aggregate statistics
 *   - trace_span: Get details of a specific span
 *   - trace_events: Get recent events from queue
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { readFileSync, readdirSync, existsSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";
import { parse as parseYAML } from "yaml";

const __dirname = dirname(fileURLToPath(import.meta.url));
const TRACE_DIR = join(__dirname, "..", "agent-trace");
const RUNS_DIR = join(TRACE_DIR, "runs");
const EVENTS_FILE = join(TRACE_DIR, "events", "queue.jsonl");

// Initialize MCP server
const server = new Server(
  {
    name: "agent-trace-mcp",
    version: "0.1.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Helper: Read span file
function readSpan(spanId) {
  const filePath = join(RUNS_DIR, `${spanId}.yaml`);
  if (!existsSync(filePath)) return null;
  try {
    const content = readFileSync(filePath, "utf-8");
    return parseYAML(content);
  } catch (e) {
    return null;
  }
}

// Helper: Get all spans
function getAllSpans() {
  if (!existsSync(RUNS_DIR)) return [];
  const files = readdirSync(RUNS_DIR).filter((f) => f.endsWith(".yaml"));
  return files.map((f) => {
    const content = readFileSync(join(RUNS_DIR, f), "utf-8");
    return parseYAML(content);
  }).filter(Boolean);
}

// Helper: Get spans for trace
function getSpansForTrace(traceId) {
  return getAllSpans().filter((s) => s.trace_id === traceId);
}

// Tool definitions
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: "trace_lineage",
      description: "Show parent-child agent spawn relationships for a trace",
      inputSchema: {
        type: "object",
        properties: {
          trace_id: {
            type: "string",
            description: "The trace ID to show lineage for",
          },
          format: {
            type: "string",
            enum: ["tree", "mermaid", "json"],
            default: "tree",
            description: "Output format",
          },
        },
        required: ["trace_id"],
      },
    },
    {
      name: "trace_runs",
      description: "List completed agent runs, optionally filtered by agent",
      inputSchema: {
        type: "object",
        properties: {
          agent_id: {
            type: "string",
            description: "Filter by agent operation name",
          },
          limit: {
            type: "number",
            default: 20,
            description: "Maximum number of runs to return",
          },
        },
      },
    },
    {
      name: "trace_stats",
      description: "Get aggregate statistics for agent runs",
      inputSchema: {
        type: "object",
        properties: {
          agent_id: {
            type: "string",
            description: "Filter stats by agent operation name",
          },
        },
      },
    },
    {
      name: "trace_span",
      description: "Get full details of a specific span",
      inputSchema: {
        type: "object",
        properties: {
          span_id: {
            type: "string",
            description: "The span ID to retrieve",
          },
        },
        required: ["span_id"],
      },
    },
    {
      name: "trace_events",
      description: "Get recent events from the event queue",
      inputSchema: {
        type: "object",
        properties: {
          limit: {
            type: "number",
            default: 20,
            description: "Maximum number of events to return",
          },
          type: {
            type: "string",
            enum: ["agent:spawn", "agent:complete", "agent:error"],
            description: "Filter by event type",
          },
        },
      },
    },
  ],
}));

// Tool handlers
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case "trace_lineage": {
      const spans = getSpansForTrace(args.trace_id);
      if (spans.length === 0) {
        return { content: [{ type: "text", text: `No spans found for trace: ${args.trace_id}` }] };
      }

      if (args.format === "mermaid") {
        let mermaid = "graph TD\n";
        for (const span of spans) {
          const shortId = span.span_id?.slice(0, 8) || "?";
          const parent = span.parent_span_id;
          const op = span.operation_name || "unknown";
          const status = span.status?.code || "UNSET";

          const style = status === "OK" ? ":::success" : status === "ERROR" ? ":::error" : "";

          if (parent && parent !== "null") {
            mermaid += `    ${parent.slice(0, 8)}["..."] --> ${shortId}["${op}"]${style}\n`;
          } else {
            mermaid += `    ${shortId}["${op} (root)"]${style}\n`;
          }
        }
        mermaid += "\nclassDef success fill:#90EE90\nclassDef error fill:#FFB6C1";
        return { content: [{ type: "text", text: mermaid }] };
      }

      if (args.format === "json") {
        return { content: [{ type: "text", text: JSON.stringify(spans, null, 2) }] };
      }

      // Default: tree format
      let tree = `TRACE LINEAGE: ${args.trace_id.slice(0, 16)}...\n${"═".repeat(50)}\n\n`;
      const roots = spans.filter((s) => !s.parent_span_id || s.parent_span_id === "null");

      for (const root of roots) {
        const icon = root.status?.code === "OK" ? "✓" : root.status?.code === "ERROR" ? "✗" : "○";
        tree += `[${icon}] ${root.operation_name} (${root.duration_ms}ms)\n`;
        tree += `    └─ span: ${root.span_id?.slice(0, 8)}...\n`;

        const children = spans.filter((s) => s.parent_span_id === root.span_id);
        for (const child of children) {
          const childIcon = child.status?.code === "OK" ? "✓" : child.status?.code === "ERROR" ? "✗" : "○";
          tree += `        └─ [${childIcon}] ${child.operation_name} (${child.duration_ms}ms)\n`;
        }
      }

      return { content: [{ type: "text", text: tree }] };
    }

    case "trace_runs": {
      let spans = getAllSpans();

      if (args.agent_id) {
        spans = spans.filter((s) => s.operation_name === args.agent_id);
      }

      spans = spans.slice(0, args.limit || 20);

      const rows = spans.map((s) => ({
        span_id: s.span_id?.slice(0, 16) + "...",
        operation: s.operation_name,
        duration_ms: s.duration_ms,
        status: s.status?.code,
        start: s.start_time,
      }));

      return { content: [{ type: "text", text: JSON.stringify(rows, null, 2) }] };
    }

    case "trace_stats": {
      const spans = getAllSpans().filter(
        (s) => s.status?.code && s.status.code !== "UNSET"
      );

      const stats = {};
      for (const span of spans) {
        const op = span.operation_name || "unknown";
        if (args.agent_id && op !== args.agent_id) continue;

        if (!stats[op]) {
          stats[op] = { count: 0, success: 0, error: 0, totalDuration: 0 };
        }
        stats[op].count++;
        if (span.status?.code === "OK") stats[op].success++;
        else stats[op].error++;
        if (span.duration_ms) stats[op].totalDuration += span.duration_ms;
      }

      const result = Object.entries(stats).map(([op, s]) => ({
        operation: op,
        runs: s.count,
        success: s.success,
        error: s.error,
        success_rate: ((s.success / s.count) * 100).toFixed(1) + "%",
        avg_duration_ms: Math.round(s.totalDuration / s.count),
      }));

      return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
    }

    case "trace_span": {
      const span = readSpan(args.span_id);
      if (!span) {
        return { content: [{ type: "text", text: `Span not found: ${args.span_id}` }] };
      }
      return { content: [{ type: "text", text: JSON.stringify(span, null, 2) }] };
    }

    case "trace_events": {
      if (!existsSync(EVENTS_FILE)) {
        return { content: [{ type: "text", text: "No events in queue" }] };
      }

      const content = readFileSync(EVENTS_FILE, "utf-8");
      let events = content
        .trim()
        .split("\n")
        .filter(Boolean)
        .map((line) => {
          try {
            return JSON.parse(line);
          } catch {
            return null;
          }
        })
        .filter(Boolean);

      if (args.type) {
        events = events.filter((e) => e.event_type === args.type);
      }

      events = events.slice(-1 * (args.limit || 20));

      return { content: [{ type: "text", text: JSON.stringify(events, null, 2) }] };
    }

    default:
      throw new Error(`Unknown tool: ${name}`);
  }
});

// Start server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Agent Trace MCP server running");
}

main().catch(console.error);
