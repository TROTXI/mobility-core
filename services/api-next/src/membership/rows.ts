// Row shapes for the membership tables, as node-postgres returns them:
// uuid and text as string, timestamptz as Date, date as Date at local
// midnight (read it through dayString), integer as number. Columns follow the
// migrations; MEM-ROWS in membership.pg.test.ts checks them against a
// migrated database, so a renamed or dropped column fails there by name.
import type { OfferTerms } from './offer-terms.js';

interface Versioned {
  id: string;
  created_at: Date;
  updated_at: Date;
  version: number;
}

export interface BillingPeriodRow {
  id: string;
  purchase_id: string;
  membership_id: string;
  user_id: string;
  starts_at: Date;
  original_ends_at: Date;
  effective_ends_at: Date;
  state: string;
}
/** A billing period read together with the purchase that funds it. */
export interface FundedPeriodRow extends BillingPeriodRow {
  fare_pesewas: number;
  offer_terms: OfferTerms | null;
}

export interface CommuteRequestRow extends Versioned {
  user_id: string;
  membership_id: string;
  period_id: string;
  selection_id: string;
  requested_date: Date;
  pause_consent: boolean;
  note: string | null;
  decision_note: string | null;
  status: string;
  slot_id: string | null;
  effective_date: Date | null;
  decided_by: string | null;
  invalidation_reason: string | null;
}

export interface CommuteSlotRow extends Versioned {
  selection_id: string;
  available_from: Date;
  state: string;
}

export interface CommuteAssignmentRow {
  id: string;
  user_id: string;
  membership_id: string;
  period_id: string;
  selection_id: string;
  purchase_id: string | null;
  request_id: string | null;
  effective_from: Date;
  effective_to: Date | null;
}

export interface MembershipPauseRow {
  id: string;
  request_id: string;
  period_id: string;
  user_id: string;
  started_at: Date;
  ended_at: Date | null;
  ends_before: Date;
  ends_after: Date | null;
  end_reason: string | null;
}

export interface ReservationRow extends Versioned {
  user_id: string;
  period_id: string | null;
  assignment_id: string | null;
  selection_id: string | null;
  direction: string;
  service_date: Date;
  trip_id: string | null;
  schedule_id: string | null;
  pattern_version_id: string | null;
  pickup_occurrence_id: string | null;
  dropoff_occurrence_id: string | null;
  status: string;
  source: string;
  settled_at: Date | null;
}

export interface RestrictionRow extends Versioned {
  user_id: string;
  actor_user_id: string;
  reason: string;
  review_at: Date;
  released_at: Date | null;
  released_by: string | null;
  release_reason: string | null;
}

export interface TripRow {
  id: string;
  schedule_id: string;
  pattern_version_id: string;
  scheduled_at: Date;
  assigned_driver_id: string | null;
  vehicle_id: string | null;
  status: string;
  current_stop_occurrence_id: string | null;
  started_at: Date | null;
  completed_at: Date | null;
  version: number;
  updated_at: Date;
  created_at: Date;
  departure_id: string;
  service_date: Date;
  run_number: number;
}

export interface MembershipRow {
  id: string;
  user_id: string;
  lifecycle: string;
  created_at: Date;
  ended_at: Date | null;
}

export interface MembershipCommandRow {
  id: string;
  actor_user_id: string;
  operation: string;
  target: string;
  key_hash: string;
  input_hash: string;
  resource_id: string;
  created_at: Date;
}
