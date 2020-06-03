package org.eclipse.gemoc.execution.concurrent.ccsljavaxdsml.api.core

import java.util.ArrayList
import java.util.HashSet
import java.util.List
import java.util.Set
import org.eclipse.gemoc.trace.commons.model.generictrace.GenericParallelStep
import org.eclipse.gemoc.trace.commons.model.generictrace.GenericSmallStep
import org.eclipse.gemoc.trace.commons.model.generictrace.GenerictraceFactory
import org.eclipse.gemoc.trace.commons.model.trace.ParallelStep
import org.eclipse.gemoc.trace.commons.model.trace.SmallStep
import org.eclipse.gemoc.trace.commons.model.trace.Step

abstract class AbstractInterpretingConcurrentExecutionEngine<C extends AbstractConcurrentModelExecutionContext<R, ?, ?>, R extends IConcurrentRunConfiguration> extends AbstractConcurrentExecutionEngine<C, R> {

	/**
	 * Compute the atomic steps currently available.
	 */
	def abstract Set<? extends GenericSmallStep> computePossibleSmallSteps()

	/**
	 * Create a clone of the given small step, assuming that this step has previously been created by this engine.
	 */
	def abstract GenericSmallStep createClonedSmallStep(GenericSmallStep gss)

	/**
	 * Return true if the two small steps are equal, assuming that the steps have previously been created by this engine.
	 */
	def abstract boolean isEqualSmallStepTo(GenericSmallStep step1, GenericSmallStep step2)

	/**
	 * Compare the two steps (previously generated by this engine) and return true if they could run concurrently.
	 * 
	 * Assumed to be computing a reflexive and symmetric relation.
	 */
	// TODO: Change parameter types to GenericSmallStep for clarity
	// TODO: Cache results as this will likely be invoked multiple times for the same combination of steps 
	def abstract boolean canInitiallyRunConcurrently(Step<?> s1, Step<?> s2)

	extension static val GenerictraceFactory traceFactory = GenerictraceFactory.eINSTANCE

	override protected computeInitialLogicalSteps() {

		var Set<ParallelStep<?, ?>> possibleLogicalSteps = new HashSet<ParallelStep<?, ?>>()

		val atomicSteps = computePossibleSmallSteps

		possibleLogicalSteps += atomicSteps.generateConcurrentSteps.map [ seq |
			if (seq.subSteps.length > 1) {
				seq
			}
		].filterNull

		possibleLogicalSteps += atomicSteps.map [ s |
			// Concurrent engine expects everything to be a parallel step
			val GenericParallelStep pstep = createGenericParallelStep
			pstep.subSteps += s

			pstep
		].toSet

		possibleLogicalSteps
	}

	/**
	 * Generate all possible maximally concurrent steps
	 * 
	 * @param atomicSteps all current atomic steps
	 */
	private def Set<GenericParallelStep> generateConcurrentSteps(Set<? extends GenericSmallStep> atomicSteps) {
		var possibleSequences = new HashSet<GenericParallelStep>

		atomicSteps.toList.createAllStepSequences(possibleSequences, new HashSet<GenericSmallStep>)

		possibleSequences
	}

	/**
	 * Compute all maximally concurrent steps
	 */
	private def void createAllStepSequences(List<? extends GenericSmallStep> allSmallSteps,
		Set<GenericParallelStep> possibleSequences, Set<GenericSmallStep> currentStack) {
		val foundOne = new ArrayList(#[false])
		
		allSmallSteps.forEach[s, idx|
			if (s.canRunConcurrentlyWith(currentStack)) {
				foundOne.set(0, true)
				
				var clonedStack = new HashSet<GenericSmallStep>(currentStack)
				clonedStack += s
					allSmallSteps.subList(idx + 1, allSmallSteps.length) // Only include elements to the right of the current element
					             .createAllStepSequences(possibleSequences, clonedStack)					
			}
		]
		
		if (!foundOne.get(0)) {
			possibleSequences.addNewParallelStep(currentStack)
		}
	}

	private def addNewParallelStep(Set<GenericParallelStep> possibleSequences, Set<GenericSmallStep> currentStack) {
		// Only add if not a sub-set of an already existing parallel step
		if (!possibleSequences.exists[parStep | currentStack.forall[newStep | parStep.subSteps.filter(GenericSmallStep).exists[subStep | subStep.isEqualSmallStepTo (newStep)]]]) {
			val pstep = createGenericParallelStep
			pstep.subSteps += currentStack.map[createClonedSmallStep]
			
			possibleSequences += pstep			
		}
	}

	/**
	 * Check if a given small step can run in parallel with a given set of other small steps.
	 * 
	 * @returns true if the given step can run concurrently with all steps in otherSteps
	 */
	private def canRunConcurrentlyWith(SmallStep<?> step, Set<GenericSmallStep> otherSteps) {
		otherSteps.forall[step.canRunConcurrentlyWith(it)]
	}

	/**
	 * Check if two small steps can be executed in parallel. First checks if the two matches can run in parallel in principle, 
	 * using canInitiallyRunConcurrently. Then checks if all concurrency strategies agree that they should be run in parallel.
	 * 
	 * @returns true if the two small steps can run in parallel
	 */
	private def canRunConcurrentlyWith(SmallStep<?> step1, SmallStep<?> step2) {
		canInitiallyRunConcurrently(step1, step2) && applyConcurrencyStrategies(step1, step2)
	}
}
